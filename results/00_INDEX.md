# Results index

This folder holds one authoritative, human-readable artifact per thesis-relevant
analysis, organised by evidential status. The filenames below are the **actual files
in this repository** (not planned/export names). The full verified genealogy of every
result, including analyses whose numbers live inside a consolidated log, is in
[`RESULTS_GENEALOGY.md`](RESULTS_GENEALOGY.md).

Interpretation is kept deliberately careful: findings are described as not reproducing
at the reported magnitude or stability; equivalence tests report effects as *excluded*
or *unresolved*; never as proof that no effect exists.

## Primary

| File | Theme | What it shows |
|---|---|---|
| `primary/study1/study1_results.log` | primary group comparison | Confirmatory triple-network NBS: no connected component survived FWER (n = 0). |
| `primary/study1/tost_ancova_runtime.txt` | primary group comparison | Targeted ANCOVA (within-DMN p=.650, DMN-ECN p=.653) and equivalence testing (original-scale effects excluded); covariate balance. |
| `primary/study1/results_check_domains.txt` | primary group comparison | Coarse domain-level comparison: 0/6 significant (uncorrected, Bonferroni, FDR). |
| `primary/study2/tost_study2_exact_runtime.txt` | Study 2 dynamics | Exact paired TOST: untreated unresolved (.0820), combined excluded (.0279), NFB excluded (.0191), all-29 excluded (.0061). |
| `primary/study2/study2_final_missing_results.txt` | Study 2 dynamics | Pre-post per group, posterior-DMN, NeuroMark 1.0 sensitivity, and leave-one-out (all-DMN within LOO [.128,.834]). |

## Sensitivity

| File | Theme | What it shows |
|---|---|---|
| `sensitivity/edge_level/tost_peredge_runtime.txt` | edge-level equivalence | Per-edge TOST (primary pipeline): 20/52 excluded at d=.606, 33/52 at d=.671. |
| `sensitivity/edge_level/tost_peredge_v25_runtime.txt` | edge-level equivalence | Per-edge TOST (v25): 23/52 (44%) and 28/52 (54%). |
| `sensitivity/network_definition/results_dataica_group.txt` | parcellation | Data-driven ICA group comparison: 1/15 nominal, 0 after Bonferroni. |
| `sensitivity/estimator/lagshift_study1_runtime.txt` | connectivity metric | Zero-lag vs lag-shift (max-\|r\|, ±4 TRs): r=.836, +23% inflation, 0/105 survive FDR under either metric. The conclusion does not depend on the estimator. |

## QC / forensic

| File | Theme | What it shows |
|---|---|---|
| `qc/perm_null_runtime.txt` | multiplicity | Empirical permutation null: expected 2.60; observed S1=1 (p_emp=.874), S2=3 (p_emp=.456); dependence inflation ~1.3x. |

## Audit / consolidated

| File | Theme | What it shows |
|---|---|---|
| `audit/corrected_results_runtime.txt` | consolidated | Combined run: chance audit, per-edge, permutation, overlap/dependence (57%; 3/7 not 8/13), ICA matching, spatial validation (Smith RSN). |
| `audit/key_results.txt` | consolidated | Key numbers gathered in one place, including data-driven ICA matching. |

## Documentation

| File | What it holds |
|---|---|
| `RESULTS_GENEALOGY.md` | The full verified genealogy of every result, with status and source. |
| `superseded/README.md` | Note on removed/superseded material (e.g. the misnamed bayes_ancova duplicate). |

## Analyses documented in the genealogy

A few finding-by-finding and exploratory analyses are recorded in
`RESULTS_GENEALOGY.md` (verified against the original paper and the per-subject data),
with their producing scripts in `code/`: Table 3 finding-by-finding (2/8 mappable),
Table 6 finding-by-finding (18 comparisons, 17 nominally significant, 3 mappable),
clinical correlations, and the Study 1 leave-one-out audit. Dedicated standalone
artifacts for these can be added later without any rerun.
