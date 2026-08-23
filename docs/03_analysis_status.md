# Analysis status: what each analysis is for

Every analysis is labelled by its role in the argument. The code does not move; only
the label tells you how much weight a result carries. Statuses: **PRIMARY**,
**CONFIRMATORY**, **SUPPORTING**, **SENSITIVITY**, **ROBUSTNESS/QC**, **EXPLORATORY**,
**SUPERSEDED**, **TEST/DEVELOPMENT**.

## Primary and confirmatory

| Script | Stage | Status | Role |
|---|---|---|---|
| `run_cnbs_H1_triple.m` | statistics | CONFIRMATORY | Prespecified FWER-controlled NBS (standard NBS, Zalesky 2010). |
| `tost_ancova.m` | statistics | PRIMARY | Targeted ANCOVA + equivalence testing (Study 1). |
| `tost_study2_exact.m` | statistics | PRIMARY | Exact paired equivalence testing, Study 2 (authoritative source of the .0820/.0279/.0191 values). |
| `stats_study2.m` | statistics | PRIMARY | Longitudinal pre-post analysis (Study 2). |
| `check_domains.m` | statistics | SUPPORTING | Coarse domain-level group comparison. |

## Sensitivity (by the choice they probe)

| Script | Stage | Probes |
|---|---|---|
| `a3_direction.m`, `direction_audit.m` | statistics | Direction stability across pipelines (preprocessing/parcellation). |
| `my_neuromark_72_v25.m`, `my_neuromark_V2.m`, `my_neuromark_Vpaper.m` | neuromark | Preprocessing/template variants. |
| `my_dataica_20.m`, `check_dataica_fnc.m`, `match_to_neuromark.m` | neuromark/fnc | Data-driven ICA (parcellation). |
| `my_neuromark10_study2.m`, `dmn10_study2.m` | neuromark/utils | NeuroMark 1.0 network-definition (Study 2). |
| `lagshift_study1.m` | fnc | Connectivity estimator (zero-lag vs lag-shift). |
| `tost_peredge.m`, `tost_peredge_v25.m` | statistics | Edge-level equivalence granularity. |

## Robustness / QC / audit

| Script | Stage | Role |
|---|---|---|
| `perm_null.m` | statistics | Empirical permutation null. |
| `chance_audit.m` | statistics | Binomial chance baseline on the original's reported counts. |
| `outlier_audit.m` | statistics | Leave-one-out and data-quality checks. |
| `check_uncorrected.m` | statistics | Uncorrected-edge audit. |
| `overlap_audit.m` | statistics | Subgroup/dependence overlap. |
| `spatial_corr.m`, `spatial_corr20.m` | utils | Spatial validation against Smith (2009) RSNs. |
| `corr_qc_study2.m`, `mean_fd.py`, `qc_image.py` | fnc/utils | Quality control. |

## Finding-by-finding / explanatory

| Script | Stage | Role |
|---|---|---|
| `table3_full.m` | statistics | Study 1 Table-3 reproduction (dual criterion). |
| `table6_full.m` | statistics | Study 2 Table-6 reproduction. |
| `repro1012_full.m`, `pair1012_study2.m` | statistics | Central "10-12" finding + sub-claims. |
| `clinical_corr.m` | statistics | Clinical-biomarker correlations (EXPLORATORY). |

## Descriptive / utility (SUPPORTING)

`describe_study2.m`, `describe_tn_study2.m`, `describe_papermap_study2.m`,
`dmn_centroids.m`, `dmn_centroids_nm10.m`, `dmn_peaks_nm10.m`, `rsn_dmn_centroids.m`,
`postdmn_22.m`, `tag_paper_map_study2.m`, `check_graymatter.m`, `match_v2.m`, `match_v3.m`.

## Superseded / historical (kept for provenance, never reported)

| Item | Status | Replaced by |
|---|---|---|
| `run_cnbs.m`, `run_cnbs_72.m`, `run_nbs.m`, `run_nbs_72.m` | PILOT / HISTORICAL | `run_cnbs_H1_triple.m` (final FWER branch). |
| old `H1` with Inf test statistics | SUPERSEDED (implementation pathology) | `nbs_work72_H1_FIXED` (authoritative, n = 0). |
| `tost_study1.m`, `tost_study1_fixed.m` | SUPERSEDED | `tost_ancova` (final). Contain unadjusted JZS Bayes factors (BF10/BF01) for the two-sample t-test, not a Bayesian ANCOVA; historical only. |
| `tost_study1_covar*.m`, `tost_perpair.m` | SUPERSEDED | `tost_ancova` (final). |
| `tost_study2.m` (grid-based Study 2 TOST) | SUPERSEDED | `tost_study2_exact.m`. |
| `match_v2.m` | SUPERSEDED | `match_v3.m`. |

## Test / development (excluded from results)

`my_neuromark_test.m`, `dmn10_fix.m`, `check_nm10.m`, `my_neuromark_20.m`, and the
`output_test/` outputs are development/debugging only and are not scientific results.


## On Bayesian ANCOVA

No standalone Bayesian ANCOVA was run. A file previously named `bayes_ancova_runtime.txt`
turned out to be a misnamed duplicate of the `tost_ancova.m` output (ANCOVA + TOST, no
Bayes factors) and was removed to avoid confusion. Note: `tost_study1.m` /
`tost_study1_fixed.m` (historical) contain unadjusted JZS Bayes factors for the
two-sample t-test, which is a different, superseded analysis.
