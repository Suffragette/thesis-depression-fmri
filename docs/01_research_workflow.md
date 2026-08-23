# Research-process trees: the actual path followed

These trees reconstruct the **actual analytical course** of the project. They are
not hypothetical analysis plans. Each one shows *why* a given analysis was
performed, *what question* motivated it, and *which alternative explanation* it was
intended to test.

They are provided as a navigable record so that anyone (including future readers,
reviewers, or an AI assistant helping assemble the manuscript) can trace the logic
behind every analysis.

Trees A to J are process diagrams. The final section is a plain-language summary,
not a diagram.

> **On interpretation.** The nodes below describe the *process* (what was asked and
> found at each step), not polished conclusions. The careful, final wording of the
> claims lives in the thesis itself and in `docs/03_decision_rules.md`. In
> particular, the reanalysis is described as a *standardised* reanalysis framework
> (not "/superior"), and the sensitivity branches *examine* the influence of
> selected choices; they do not isolate the causal effect of any single choice.

---

## Tree A: Overall research path

```
Bezmaternykh et al. (2021)
        │
        ├── Original Study 1:
        │      cross-sectional depression vs healthy controls
        │      specific ICA-derived connectivity findings
        │
        └── Original Study 2:
               longitudinal / treatment-related connectivity findings
                         │
                         ▼
               Reproducibility question
                         │
                         ▼
        Same publicly available data / related datasets
                         │
                         ▼
       Standardized reanalysis framework
             fMRIPrep + NeuroMark
                         │
             ┌───────────┴───────────┐
             ▼                       ▼
          STUDY 1                 STUDY 2
      cross-sectional            longitudinal
             │                       │
             ▼                       ▼
      Primary NeuroMark 2.2     Primary NeuroMark 2.2
             │                       │
             ▼                       ▼
      Targeted findings         Three directly mapped
      + confirmatory NBS        longitudinal findings
             │                       │
             ▼                       ▼
       Did they reproduce?       Did they reproduce?
             │                       │
       NO / weak effects          NO statistically
             │                       │
             ▼                       ▼
     Why not? Could an           Is the non-reproduction
     analytical choice           conclusive or merely
     explain this?               imprecise?
             │                       │
             ▼                       ▼
      Sensitivity branches          TOST
             │                       │
             ▼                       ▼
   preprocessing / estimator    different answers by target
   / network representation         │
             │                       ▼
             └──────────────► integrated reproducibility
                              interpretation
```

The project is therefore **not** a linear "run one pipeline and report null results"
study. It evolved by asking, after each primary discrepancy, which plausible
analytical explanation could be examined directly.


---

## Tree B: How the Study 1 investigation developed

```
Original Study 1 findings
        │
        ├── within-DMN finding
        └── DMN–ECN finding
                 │
                 ▼
      Primary NeuroMark 2.2 representation
                 │
                 ├── DMN = ICNs 94–101
                 ├── ECN = ICNs 91–93
                 └── SAL = ICNs 102–105
                 │
                 ▼
        Targeted domain summaries
                 │
                 ├── within-DMN
                 └── DMN–ECN
                 │
                 ▼
      Covariate-adjusted group analysis
      age + sex + mean FD
                 │
                 ▼
            No significant
        targeted group differences
                 │
                 ▼
       QUESTION 1:
       Is this simply a failure
       of uncorrected pairwise NHST?
                 │
                 ▼
      Confirmatory triple-network NBS
      FWER-controlled
                 │
                 ▼
       no surviving component
                 │
                 ▼
       QUESTION 2:
       Does “non-significant” merely mean
       insufficient precision?
                 │
                 ▼
              TOST
                 │
                 ▼
       paper-scale effects excluded
       for targeted Study 1 summaries
                 │
                 ▼
       QUESTION 3:
       Could preprocessing explain
       the non-reproduction?
                 │
       ┌─────────┼──────────────┐
       ▼         ▼              ▼
    Vpaper      V2          fMRIPrep v25
 paper-like   no aCompCor     sensitivity
 preprocessing
       │         │              │
       └─────────┴──────────────┘
                 │
                 ▼
       targeted findings remain
          non-significant
                 │
                 ▼
       direction not fully stable
                 │
                 ▼
       QUESTION 4:
       Could connectivity estimator
       explain the discrepancy?
                 │
          zero-lag vs lag-shift
                 │
                 ▼
          r ≈ .836 between
          connectivity estimates
                 │
                 ▼
       lag-shift does NOT restore
       the targeted findings
                 │
                 ▼
       no FDR-surviving connection
       under either estimator
                 │
                 ▼
        STUDY 1 CLOSED:
        no tested single analytical
        modification restores the
        original pattern
Key logic: preprocessing and estimator were tested as candidate explanations because the primary result failed to reproduce. They are not decorative robustness analyses added afterwards.
The preprocessing audit showed that the within-DMN result remained non-significant across the baseline, paper-oriented, v25 and no-aCompCor variants, with sign instability across pipelines.
The estimator branch showed strong correspondence between zero-lag and lag-shift FNC ((r=.836)), but neither estimator recovered the prespecified Study 1 effects and no connection survived FDR.
```

---

## Tree C: Why the Study 1 NBS branch exists

```
Original Study 1
multiple pairwise tests
uncorrected p-values
        │
        ▼
Question:
Are there network-level group differences
that survive multiplicity control?
        │
        ▼
Restrict analysis to hypothesis-relevant
triple-network set
ECN + DMN + Salience
15 NeuroMark ICNs
        │
        ▼
NBS
F-test
extent threshold = 3.1
5000 permutations
FWER alpha = .05
        │
        ▼
Final saved result
n = 0
        │
        ▼
No connected component survived
This branch answers a different question from the two domain-summary ANCOVAs.
Do not collapse them into one analysis.
```

---

## Tree D: Why the Study 1 TOST branch exists

```
Targeted Study 1 tests:
p > .05
        │
        ▼
Problem:
NHST alone cannot distinguish
"approximately small effect"
from
"very imprecise estimate"
        │
        ▼
Use paper-derived effect magnitudes
as prespecified equivalence bounds
        │
        ▼
ANCOVA-based TOST
        │
        ├── within-DMN
        └── DMN–ECN
        │
        ▼
paper-scale bounds excluded
        │
        ▼
Interpretation:
stronger than "not significant"
but weaker than "effect = 0"
This is why TOST belongs centrally in the thesis rather than as an optional statistical appendix.
```

---

## Tree E: How the Study 2 investigation developed

```
Original Study 2 longitudinal findings
        │
        ├── untreated:
        │      within-DMN decrease
        │
        ├── combined treatment:
        │      DMN–ECN increase
        │
        └── neurofeedback:
               DMN–ECN increase
                  │
                  ▼
       Primary NeuroMark 2.2 mapping
                  │
                  ▼
       paired pre–post comparisons
                  │
                  ▼
       none statistically reproduced
                  │
                  ▼
        QUESTION 1:
        Is non-reproduction conclusive?
                  │
                  ▼
              Exact TOST
                  │
        ┌─────────┼──────────┐
        ▼         ▼          ▼
    untreated   combined     NFB
    pTOST=.082  .0279       .0191
        │         │          │
        ▼         ▼          ▼
   unresolved   original-   original-
   at original  scale       scale
   magnitude    excluded    excluded
        │
        └─────────┬──────────┘
                  │
                  ▼
        QUESTION 2:
        Could network representation
        explain directional discrepancies?
                  │
                  ▼
          NeuroMark 1.0 sensitivity
                  │
          ┌───────┴────────┐
          ▼                ▼
   posterior/anterior   alternative
       DMN split        DMN–CC proxy
          │                │
          ▼                ▼
  some original         some directions
  directions recover    recover
          │                │
          └───────┬────────┘
                  ▼
       but statistical reproduction
       is still not obtained
                  │
                  ▼
      STUDY 2 CONCLUSION:
      evidence differs by finding,
      and some conclusions depend
      on network representation
The exact TOST branch is crucial. The untreated result remained unresolved at the original effect magnitude, whereas the combined-treatment and NFB original-scale effects were excluded.
```

---

## Tree F: Posterior-DMN investigation

```
This branch was not arbitrary. It arose because the original longitudinal claim concerned a more specific DMN configuration than a whole-domain average.
Primary whole-DMN representation
        │
        ▼
Original longitudinal DMN finding
not reproduced
        │
        ▼
Question:
Are we averaging across anatomically/
functionally distinct DMN subdivisions?
        │
        ▼
Try posterior-DMN representation
under primary NeuroMark 2.2
        │
        ▼
direction still disagrees
        │
        ▼
Alternative NeuroMark 1.0
posterior/anterior representation
        │
        ▼
posterior-DMN direction agrees
with original finding
        │
        ▼
but p remains non-significant
        │
        ▼
anterior-DMN behaves differently
        │
        ▼
Conclusion:
network definition matters for
directional interpretation,
but does not provide statistical
replication of the original finding
This is one of the strongest examples in the thesis of why “DMN connectivity” is too coarse a phrase unless the actual representation is specified.
```

---

## Tree G: Network-correspondence investigation

```
Original paper:
data-driven ICA components
        │
        ▼
Problem:
component labels are not guaranteed
to correspond one-to-one across
decompositions
        │
        ▼
NeuroMark:
standardized reference-constrained ICNs
        │
        ▼
Can original component be matched exactly?
        │
     ┌──┴──┐
     │     │
    YES    NO
     │     │
     ▼     ▼
 close     functional/domain analogue
 mapping          │
                  ▼
           explicitly qualify
           interpretation
A second reason this branch matters is that the original study itself encountered component-correspondence problems across its own analyses. Therefore, this is not merely a limitation created by the present reanalysis.
```

---

## Tree H: Preprocessing forensic audit

```
This was part of the actual project path and must not disappear from the Methods narrative.
Question:
What preprocessing was ACTUALLY applied?
        │
        ▼
Do not trust proposal / README alone
        │
        ▼
inspect producing scripts
        │
        ├── baseline
        ├── noCompCor
        ├── noBandpass
        └── paper-oriented variant
        │
        ▼
inspect load_confounds()
        │
        ▼
returns:
confounds + sample_mask
        │
        ▼
inspect clean_img()
        │
        ▼
sample_mask NOT passed
        │
        ▼
Therefore:
do not claim temporal censoring
through returned sample_mask
        │
        ▼
Methods wording corrected
to describe actual implementation
This tree is important because it demonstrates the forensic reproducibility method used throughout the thesis: claims are reconstructed from actual code, not from intention.
```

---

## Tree I: Software / provenance audit

```
Archived proposal
        │
        ├── planned analyses
        └── planned software
               │
               ▼
        NOT sufficient evidence
               │
               ▼
Repository code
        │
        ▼
working MATLAB analysis directory
        │
        ▼
runtime logs / saved .mat outputs
        │
        ▼
authoritative final numerical results
Concrete example:
Git/repository copy:
the repository copy (code only)
        │
        ▼
contains code, but not all generated outputs

Actual analysis tree:
the working analysis directory (code + outputs)
        │
        ├── output72
        ├── output_study2
        ├── runtime logs
        ├── NBS saved results
        └── figures
This distinction prevented the false conclusion that the analysis outputs had been lost.
```

---

## Tree J: Final explanatory tree: what caused non-reproduction?

```
Non-reproduction observed
        │
        ├── preprocessing?
        │      tested
        │      effects remain non-significant
        │
        ├── connectivity estimator?
        │      tested
        │      lag-shift does not restore findings
        │
        ├── network representation?
        │      tested
        │      some Study 2 directions change
        │
        ├── multiplicity/statistical instability?
        │      relevant
        │      original Study 1 uncorrected
        │
        └── limited precision/sample size?
               clearly relevant,
               especially Study 2
                  │
                  ▼
          FINAL ANSWER:
          no single causal explanation
          was isolated
This must not be flattened into a single-cause claim, e.g.:
“The difference was caused by NeuroMark.”
or:
“The difference was caused by preprocessing.”
Neither was demonstrated.
```

---

## Summary: what each branch contributes to the thesis

The branches above are not a random robustness buffet; they form a chain of
questions. Each contributes one specific thing to the argument:

- **Confirmatory NBS** establishes the primary negative result: no group difference survives family-wise-error control.
- **Targeted ANCOVA + TOST** upgrades "not found" to "excluded": the two highlighted effects are rejected at the originally reported size.
- **Chance and permutation audits** reframe the original's counts as near what chance and dependence predict.
- **Preprocessing sensitivity** rules out the pipeline as the explanation: the null persists and the sign is unstable across variants.
- **Connectivity-estimator sensitivity** rules out the metric: lag-shift changes magnitudes but does not restore the effect.
- **Parcellation sensitivity** (data-driven ICA, NeuroMark 1.0) rules out network definition and exposes the component-correspondence problem.
- **Per-edge and exact equivalence tests** quantify how much of the connectome, and which longitudinal claims, can be bounded (excluded) versus left unresolved.
- **Clinical-correlation reanalysis** shows the biomarker claims do not reproduce at the reported magnitude.
- **Overlap audit** sets the interpretive limit: Study 1 and Study 2 are not independent, so convergence is not independent evidence.
- **Spatial validation** confirms the networks are correctly identified, so the null results are not a labelling artefact.

Together they support a single, precision-aware conclusion: the original findings do
not reproduce at the reported magnitude or stability, and no single tested analytical
choice accounts for the difference.
