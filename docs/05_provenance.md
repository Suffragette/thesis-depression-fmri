# Provenance: from question to claim

For each main result, this traces the full chain: the question, the script that
answered it, the input it consumed, the output it produced, the saved runtime file
that holds the numbers, and the claim it licenses. This is what lets any number in
the thesis be traced back to a specific run.

Format: **question -> script -> input -> output -> runtime file -> claim.**

## Study 1

**Is there any group difference at all (FWER)?**
`run_cnbs_H1_triple.m` -> triple-network FNC (72 subjects) -> NBS result object ->
`nbs_work72_H1_FIXED/H1_result.mat` (mirrored in `results/primary/study1/study1_results.log`) ->
*No connected component survived FWER correction (n = 0).*

**Do the two highlighted connections differ (adjusted)?**
`tost_ancova.m` -> FNC + covariates (age, sex, mean FD) ->
ANCOVA + TOST tables -> `results/primary/study1/tost_ancova_runtime.txt` ->
*within-DMN p = .650, DMN-ECN p = .653; both original-scale effects excluded by TOST.*

**Do the coarse domains differ?**
`check_domains.m` -> domain-averaged FNC -> six-row table ->
`results/primary/study1/results_check_domains.txt` ->
*0/6 significant (uncorrected, Bonferroni, FDR); within-DMN direction reversed.*

**Do the reported counts exceed chance?**
`chance_audit.m` + `perm_null.m` -> the original's reported counts / permuted labels ->
`results/audit/`, `results/qc/perm_null_runtime.txt` ->
*Study 1 marginally above chance (p = .0193, not surviving Bonferroni); dependence inflation about 1.3x.*

## Study 1 sensitivity

**Does the direction hold across pipelines?** `a3_direction.m` -> `results/audit/corrected_results_runtime.txt` -> *sign flips across pipelines; all non-significant.*

**Does the estimator matter?** `lagshift_study1.m` -> *lag-shift inflates |r| about 23%; no FDR survivors.*

**Does the original's own ICA reproduce it?** `check_dataica_fnc.m` -> `results/sensitivity/network_definition/results_dataica_group.txt` -> *domain pairs non-significant; 1/15 connections nominal, 0 after Bonferroni.*

**How much of the connectome can be bounded?** `tost_peredge.m` -> `results/sensitivity/edge_level/` -> *38% of edges excluded at the reported effect size (63% at the larger bound).*

## Study 2

**Do the mapped longitudinal findings reproduce, and can they be excluded?**
`tost_study2_exact.m` (exact paired TOST) + `stats_study2.m` (pre/post) -> pre/post FNC per group ->
`results/primary/study2/tost_study2_exact_runtime.txt`,
`results/primary/study2/study2_final_missing_results.txt` ->
*untreated within-DMN p = .470, TOST p = .0820 (unresolved); combined DMN-ECN and NFB DMN-ECN original-scale effects excluded.*

**Does the central "10-12" finding reproduce?** `repro1012_full.m` -> `tables/main/repro1012_full.csv` -> *reconstructed against the paper's reported values; does not reproduce at the reported magnitude.*

**Do the clinical correlations reproduce?** `clinical_corr.m` (recomputed from `tables/main/repro1012_full.csv`) -> *baseline within-DMN vs ΔZung r = +.13 (paper .63); Δwithin-DMN vs ΔMADRS r = -.41 (paper -.73); neither reproduces at magnitude.*

**Network-definition sensitivity (NM1.0)?** `dmn10_study2.m` -> `study2_final_missing_results.txt` -> *posterior-DMN direction agrees with the paper, significance does not; anterior DMN significant but opposite.*

## Validation and dependence

**Are the networks correctly identified?** `spatial_corr.m` -> *Smith (2009) RSN positive control passes; DMN/ECN identified; data-driven components do not correspond cleanly.*

**Are the studies independent?** `overlap_audit.m` -> `results/audit/corrected_results_runtime.txt` -> *Study 2 is a 57% subset of Study 1; report 3/7 direction agreements with caveats, not 8/13.*
