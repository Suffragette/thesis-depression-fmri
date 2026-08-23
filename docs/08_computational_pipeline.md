# Computational pipeline: Bezmaternykh et al. (2021) vs present reanalysis

This document provides a side-by-side computational map of the original study and the present reproducibility reanalysis. Its purpose is to show **where the two workflows address the same scientific questions, where they differ computationally, and which sensitivity analyses were used to interrogate those differences**.

> **Interpretive rule:** differences between workflows are not treated as proof of why a result did or did not reproduce. They define candidate methodological explanations that were examined through explicit sensitivity analyses.

---

## 1. Side-by-side computational pipeline

```text
BEZMATERNYKH et al. (2021)                  PRESENT REANALYSIS
──────────────────────────                  ──────────────────

Public resting-state fMRI data              Same public data / corresponding derivatives
            │                                           │
            ▼                                           ▼
SPM12-based preprocessing                   fMRIPrep preprocessing
            │                                           │
            ▼                                           ▼
Paper-specific nuisance handling            Nilearn denoising / nuisance regression
            │                                           │
            ▼                                           ▼
Data-driven group ICA                       Primary NeuroMark 2.2 representation
Infomax + ICASSO                            fixed reference-constrained ICNs
            │                                           │
            ▼                                           ▼
Sample-specific independent                 Standardized ICNs mapped to
components                                  DMN / ECN / Salience domains
            │                                           │
            ▼                                           ▼
Component identification                    Network/component correspondence audit
(DMN / ECN / other RSNs)                    + functional/domain analogue where needed
            │                                           │
            ▼                                           ▼
IC time courses                             Subject-level NeuroMark postprocessing
            │                                           │
            ▼                                           ▼
Lag-shift functional connectivity           Primary zero-lag Pearson FNC
(max |r| across tested lags)                between IC time courses
            │                                           │
            ▼                                           ▼
Pairwise connectivity tests                 Targeted domain summaries
                                                ├── within-DMN
                                                └── DMN–ECN
            │                                           │
            ▼                                           ▼
Uncorrected pairwise inference              Covariate-adjusted ANCOVA
            │                                           │
            │                                           ├── age
            │                                           ├── sex
            │                                           └── mean FD
            │                                           │
            │                                           ▼
            │                               Confirmatory standard NBS
            │                               restricted to the prespecified
            │                               ECN + DMN + Salience subnetwork
            │                                           │
            │                                           ▼
            │                               FWER / FDR / multiplicity-aware inference
            │                                           │
            ▼                                           ▼
Reported Study 1 findings                   Study 1 reproducibility assessment
            │                                           │
            │                                           ├── targeted effects
            │                                           ├── NBS
            │                                           └── equivalence (TOST)
            │                                           │
            ▼                                           ▼
Study 2 longitudinal ICA/FNC                Study 2 mapped longitudinal reanalysis
            │                                           │
            ├── untreated                               ├── untreated
            ├── combined treatment                      ├── combined treatment
            └── neurofeedback                           └── neurofeedback
            │                                           │
            ▼                                           ▼
Pre–post subgroup tests                     Paired longitudinal tests
            │                                           │
            ▼                                           ▼
Reported longitudinal findings              Exact TOST at paper-derived effect bounds
                                                        │
                                                        ▼
                                             Integrated reproducibility interpretation
```

---

## 2. Where the workflows differ, and how each difference was tested

### A. Preprocessing

```text
Original: SPM12-based preprocessing
        ↓
Reanalysis: fMRIPrep + Nilearn denoising
        ↓
Sensitivity branches: Vpaper / V2 / V5 / fMRIPrep-25.x branch
        ↓
Question: Could preprocessing explain the non-reproduction?
```

**Interpretation:** the tested preprocessing variants did not restore the targeted Study 1 findings. This does **not** establish that preprocessing is causally irrelevant; it shows that the specific tested alternatives did not recover the original pattern.

### B. Network identification / parcellation

```text
Original: sample-specific data-driven ICA
        ↓
Reanalysis primary: NeuroMark 2.2 fixed reference-constrained ICNs
        ↓
Sensitivity: data-driven ICA + spatial matching
             alternative NeuroMark representation
             posterior/anterior DMN checks
        ↓
Question: Could network representation or component correspondence explain the discrepancy?
```

**Interpretation:** network representation affected some directional results, especially in Study 2, but did not establish statistical reproduction of the original findings.

### C. Connectivity estimator

```text
Original: lag-shift connectivity
        ↓
Reanalysis primary: zero-lag Pearson FNC
        ↓
Sensitivity: zero-lag vs lag-shift
        ↓
Question: Could the connectivity estimator explain the discrepancy?
```

**Observed audit result:** zero-lag and lag-shift estimates were strongly related (`r ≈ .836`), while lag-shift altered magnitudes but did not restore the prespecified Study 1 effects; no connection survived FDR under either estimator.

### D. Statistical inference

```text
Original: multiple pairwise comparisons
          reported without family-wise multiplicity correction
        ↓
Reanalysis: targeted ANCOVA + standard NBS + FDR / permutation checks
        ↓
Question: Do the reported network effects survive multiplicity-aware inference?
```

**Interpretation:** the confirmatory triple-network NBS yielded no surviving connected component in the final authoritative result.

### E. Precision and equivalence

```text
Primary reanalysis: p > .05
        ↓
Problem: non-significance does not distinguish
         a small effect from an imprecise estimate
        ↓
TOST using paper-derived effect magnitudes as equivalence bounds
        ↓
Question: Can effects of the originally reported magnitude be statistically excluded?
```

**Study 1:** paper-scale effects were excluded for the two targeted summaries.

**Study 2:** the answer differed by target: the untreated effect remained unresolved at the original magnitude, whereas the combined-treatment and neurofeedback original-scale effects were excluded.

---

## 3. Computational branch tree of the present reanalysis

```text
PUBLIC DATA / DERIVATIVES
        │
        ▼
fMRIPrep
        │
        ▼
Nilearn denoising
        │
        ├── baseline
        ├── no-aCompCor sensitivity
        ├── paper-oriented sensitivity
        ├── no-bandpass branch
        └── fMRIPrep-version sensitivity
        │
        ▼
GIFT / NeuroMark
        │
        ├── NeuroMark 2.2 primary representation
        ├── alternative NeuroMark representation
        └── data-driven ICA sensitivity
        │
        ▼
Subject-level postprocessing
        │
        ▼
FNC
        │
        ├── zero-lag Pearson primary estimator
        └── lag-shift sensitivity
        │
        ▼
STATISTICS
        │
        ├── targeted ANCOVA
        ├── confirmatory standard NBS
        ├── FDR / multiplicity checks
        ├── empirical permutation null
        ├── TOST / SESOI
        ├── per-edge analyses
        ├── outlier / LOO audit
        └── Study 2 paired longitudinal tests
        │
        ▼
FINDING-BY-FINDING COMPARISON
        │
        ├── Study 1 paper findings
        ├── Study 2 longitudinal findings
        ├── clinical correlations
        └── component/network correspondence
        │
        ▼
INTEGRATED REPRODUCIBILITY ASSESSMENT
```

---

## 4. Thesis-use version

For the thesis, this pipeline should support three separate methodological claims:

1. **Same scientific targets, different standardized computational framework.**
2. **Every major divergence from the original workflow was made explicit rather than hidden.**
3. **Sensitivity analyses were used diagnostically to test whether selected analytical choices could account for non-reproduction; no single causal explanation was isolated.**

The diagram should therefore **not** be captioned as showing a “better” or “superior” pipeline. A safer formulation is:

> **Figure X. Computational workflow of Bezmaternykh et al. (2021) and the present reproducibility reanalysis.** The reanalysis addressed the original scientific targets using fMRIPrep, NeuroMark and multiplicity-aware inference. Major workflow differences generated explicit sensitivity branches examining preprocessing, network representation and connectivity estimation. These branches were used to assess robustness and possible sources of discrepancy, not to assign a single causal explanation for non-reproduction.

---
