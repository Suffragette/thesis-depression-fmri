# Analysis map: what each analysis does, why, and where its result lives

This file connects every analysis to (1) the research question it answers,
(2) its role in the argument (**primary**, **sensitivity**, or **exploratory**),
and (3) the result file that holds its numbers. The classification follows the
project's own rule: sensitivity and exploratory analyses are never silently
promoted to primary findings.

Numbers themselves are **not** repeated here; each entry points to the actual
results file (under `results/`) where the verified output lives. For a single
index of every result file see [`results/00_INDEX.md`](../results/00_INDEX.md),
and for the full verified genealogy (including analyses whose numbers live inside
a consolidated runtime log) see
[`results/RESULTS_GENEALOGY.md`](../results/RESULTS_GENEALOGY.md).

---

## The pipeline in four stages

| Stage | Folder | What happens |
|---|---|---|
| 1. Preprocessing | `code/01_preprocessing/` | fMRIPrep-based denoising and the denoising variants (V0 baseline, V2 no-aCompCor, V5 no-bandpass, Vpaper paper-matched). |
| 2. Network identification | `code/02_neuromark/` | NeuroMark 2.2 spatially-constrained ICA identifies the triple-network components; a data-driven ICA (Infomax+ICASSO) reproduces the original's own approach. |
| 3. Connectivity | `code/03_fnc/` | Functional network connectivity (Fisher-z correlations), plus the lag-shift estimator for comparison. |
| 4. Statistics & inference | `code/04_statistics/` | The confirmatory and targeted tests, equivalence testing, finding-by-finding comparisons, and robustness checks. |

Triple-network component indices (verified from the code): **ECN 91–93, DMN 94–101,
salience 102–105**.

---

## Study 1: cross-sectional (depression vs healthy controls)

### Primary
| Analysis | Question it answers | Result file |
|---|---|---|
| `run_cnbs_H1_triple.m` | Does **any** connected subnetwork differ between groups, controlling family-wise error? | `results/primary/study1/study1_results.log` |
| Targeted within-DMN and DMN–ECN group effects (ANCOVA-adjusted for age, sex, motion) | Do the **two connections the original highlighted** differ here? | *(from runtime: `study1_results.log` / `tost_ancova_runtime.txt`)* |
| Equivalence testing (TOST) against paper-derived effect-size bounds | Can a difference **as large as the one reported** be excluded? | `results/primary/study1/tost_ancova_runtime.txt` |
| `check_domains.m` | Do the coarse DMN/ECN/salience domain-pairs differ after correction? | `results/primary/study1/results_check_domains.txt` |

### Chance baseline
| Analysis | Question it answers | Result file |
|---|---|---|
| `chance_audit.m` | Do the original's **reported** "significant" counts exceed what chance predicts (no data used)? | `results/audit/corrected_results_runtime.txt` (consolidated) |
| `perm_null.m` | Empirical chance null over the 52 triple-network edges (dependence-preserving). | `results/qc/perm_null_runtime.txt` |

### Sensitivity (do NOT promote to primary)
| Analysis | Question it answers | Result file |
|---|---|---|
| `a3_direction.m` | Is the **direction** of the effect stable across four reasonable pipelines? | `results/audit/corrected_results_runtime.txt` (consolidated) |
| `check_dataica_fnc.m` + `match_to_neuromark.m` | Does it reproduce under the **original's own** data-driven ICA (Infomax+ICASSO, 20 comp)? | `results/sensitivity/network_definition/results_dataica_group.txt`; ICA matching in `results/audit/key_results.txt` |
| `lagshift_study1.m` | Does the conclusion depend on the **connectivity metric** (zero-lag vs lag-shift)? | `results/sensitivity/estimator/lagshift_study1_runtime.txt` |

### Finding-by-finding & robustness
| Analysis | Question it answers | Result file |
|---|---|---|
| `table3_full.m` | For each of the original's eight Table-3 connections, does it reproduce in direction and significance? | documented in `results/RESULTS_GENEALOGY.md` (2/8 mappable) |
| `outlier_audit.m` | Is the null driven by any single participant or by data-quality issues? | leave-one-out in `results/primary/study2/study2_final_missing_results.txt`; see `results/RESULTS_GENEALOGY.md` |

---

## Study 2: longitudinal (treatment-related change)

### Primary
| Analysis | Question it answers | Result file |
|---|---|---|
| `stats_study2.m` | What are the pre-post connectivity changes per group (NT / CBT / NFB), with confidence intervals? | `results/primary/study2/study2_final_missing_results.txt` |
| Three directly mapped longitudinal findings + exact TOST | Do the mapped treatment-related findings reproduce, and can the reported effects be excluded? | *(from runtime: `study2_final_missing_results.txt`, `tost_study2_exact_runtime.txt`)* |

### Finding-by-finding
| Analysis | Question it answers | Result file |
|---|---|---|
| `table6_full.m` | Of the eighteen Table-6 comparisons (17 nominally significant), how many are testable in triple-network scope, and do they reproduce? | documented in `results/RESULTS_GENEALOGY.md` (3 mappable) |
| `repro1012_full.m` | Does the central "10-12" finding and its five sub-claims reproduce? | `results/primary/study2/study2_final_missing_results.txt`; see `results/RESULTS_GENEALOGY.md` |

### Exploratory / additional (kept subordinate)
| Analysis | Question it answers | Result file |
|---|---|---|
| `clinical_corr.m` | Do the treatment-response **correlations** (Tables 7–10) reproduce? Includes a power reality-check on the original's very small samples. | documented in `results/RESULTS_GENEALOGY.md` |

---

## The one rule that governs all of the above

Primary findings carry the argument. Sensitivity analyses **rule out** specific
alternative explanations by showing the result does not change under a different
choice; they do not isolate the causal effect of any single choice, and they are
never presented as primary. Exploratory analyses (clinical correlations, broader
edge-level searches, direction audits) stay explicitly subordinate.
