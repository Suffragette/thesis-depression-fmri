# Results genealogy: every result, its status, and its source

This file records all results the project produced, with a **status** so that primary
evidence is never confused with sensitivity, exploratory, quality-control (QC), or
superseded output.

**Verification.** The numbers below were read from the saved runtime output of the
analysis (`study1_results.log`, `corrected_results_runtime.txt`,
`tost_ancova_runtime.txt`, `tost_study2_exact_runtime.txt`,
`study2_final_missing_results.txt`, `perm_null_runtime.txt`, `key_results.txt`, and
the per-subject `repro1012_full.csv`). Where an independent recomputation was possible
(the chance audit, the clinical correlations) it agrees with those outputs.

| Status | Meaning |
|---|---|
| PRIMARY | Carries the main argument. |
| SENSITIVITY | Tests whether a primary result changes under a different analytical choice. Never promoted to primary. |
| EXPLORATORY | Additional, kept explicitly subordinate. |
| QC / FORENSIC | Diagnostic checks (robustness, outliers, chance baselines, spatial validation). |
| SUPERSEDED / INVALID | Genuinely produced but replaced or diagnostic-only; kept for provenance, not for reporting. |

Wording, kept consistent with the thesis: results are described as *not reproducing at
the reported magnitude or stability*; equivalence tests report an effect as *excluded*
or *unresolved*; never as *proof that no effect exists*.

---

## LEVEL 1: Primary evidence

### Study 1 (cross-sectional)

**Covariate balance** (groups are comparable, so adjustment changes little)
age: depressed 32.8 ± 8.9, control 33.8 ± 8.5, t(70) = −0.45, p = .654 · FD: 0.0825 vs
0.0852, t(70) = −0.28, p = .781 · sex: 13m/38f vs 6m/15f, chi-square(1) = 0.07, p = .787.

**Confirmatory triple-network NBS**: PRIMARY
Source: `nbs_work72_H1_FIXED/H1_result.mat` (n = 0, con_mat = [], pval = [], test_stat
15×15). F-test, threshold primary group comparison, 5,000 permutations, FWER alpha = .05.
Result: **no connected component survived FWER correction.**

**Targeted ANCOVA group effects** (adjusted for age, sex, mean FD; df = 67): PRIMARY
- within-DMN: adjusted diff +0.00719, SE 0.01575, t(67) = +0.456, p = .6496, 95% CI [−0.0243, +0.0386], d = 0.12
- DMN–ECN:  adjusted diff +0.00809, SE 0.01790, t(67) = +0.452, p = .6528, 95% CI [−0.0276, +0.0438], d = 0.12
Neither highlighted connection differed between groups after adjustment.

**Equivalence testing (TOST), ANCOVA-based**: PRIMARY (residual-SD)
- within-DMN: d = .606 → p_TOST = .0325 (EXCLUDED); d = .671 → .0186 (EXCLUDED); smallest rejectable |d| = 0.60
- DMN–ECN:  d = .606 → p_TOST = .0322 (EXCLUDED); d = .671 → .0184 (EXCLUDED); smallest rejectable |d| = 0.60
Effects of the originally reported magnitude are excluded for these two connections.

### Study 2 (longitudinal): exact paired TOST

- **Untreated within-DMN** (n = 15): mean Δz = +0.0130, dz = +0.192, t(14) = +0.74, p = .470, 95% CI [−0.0246, +0.0507]. Exact TOST at paper dz = .571: p_TOST = **.0820 → NOT excluded (unresolved)**; smallest rejectable |dz| = 0.65.
- **Combined treatment DMN–ECN** (n = 14): Δz = −0.0085, dz = −0.091, t(13) = −0.34, p = .740, 95% CI [−0.0626, +0.0456]. Exact TOST at dz = .652: p_TOST = **.0279 → EXCLUDED.**
- **Neurofeedback DMN–ECN** (n = 6): Δz = −0.0240, dz = −0.227, t(5) = −0.56, p = .602, 95% CI [−0.1349, +0.0869]. Exact TOST at dz = 1.368: p_TOST = **.0191 → large effect EXCLUDED** (n = 6 cannot exclude small effects).
- **All 29 within-DMN** (descriptive): Δz = −0.0054, dz = −0.074, p = .694, 95% CI [−0.0332, +0.0224]. Exact TOST at dz = .571: p_TOST = **.0061 → EXCLUDED.**

---

## LEVEL 2: Targeted robustness (SENSITIVITY, not promoted to primary)

**Per-edge equivalence (primary pipeline).** within-DMN + DMN–ECN = 52 edges.
d = .606 → 20/52 excluded (38%), 1 nominally significant, observed |d| median 0.20 max 0.54; d = .671 → 33/52 (63%).

**Per-edge equivalence (v25 sensitivity).** d = .606 → 23/52 (44%), 5 nominally significant, median |d| 0.22 max 0.83; d = .671 → 28/52 (54%).

**Sign instability (v25 vs primary).** within-DMN: depressed +0.0527 vs control +0.0603 → control > depressed, p = .603; DMN–ECN: +0.0127 vs +0.0049 → depressed > control, p = .475. In the 2.2 pipeline within-DMN was depressed > control. Direction flips across pipelines (both non-significant).

**Scale / dilution.** Paper 10–12 raw change −0.140. Our within-DMN edges: |raw change| median 0.033, max 0.144; per-edge SD of change 0.216; SD of the 28-edge mean 0.068; dilution ≈ 3.2×. A single-edge change of 0.140 appears as 0.0050 in the 28-edge mean.

**Network-definition sensitivity (NeuroMark 1.0), Study 2.**
- Untreated posterior-DMN: Δz = −0.0260, t(14) = −1.27, p = .225 → direction now AGREES with the paper's decrease, significance not recovered.
- Untreated whole DMN: Δz = +0.0002, p = .992. Untreated anterior DMN: Δz = +0.1452, t(14) = +2.78, p = .015 (nominally significant, opposite pattern).
- Combined DMN–CC: Δz = −0.0083, p = .378; posterior-DMN–CC: Δz = −0.0094, p = .405 (both opposite the paper's increase).
- Neurofeedback DMN–CC: Δz = +0.0181, p = .201; posterior-DMN–CC: Δz = +0.0159, p = .282 (direction agrees, significance does not).

**Posterior-DMN under primary NeuroMark 2.2 (untreated), with leave-one-out.**
- posterior-DMN within (6 pairs): Δz = +0.0195, dz = +0.11, t(14) = +0.44, p = .670, CI [−0.076, +0.115]; LOO p range [0.227, 0.999].
- posterior-DMN ↔ ECN (12 pairs): Δz = −0.0230, dz = −0.26, t(14) = −1.02, p = .324, CI [−0.071, +0.025]; LOO p [0.093, 0.574].
- all-DMN within (28 pairs): Δz = +0.0130, dz = +0.19, t(14) = +0.74, p = .470; **LOO p [0.128, 0.834]** (no single participant drives the null).

---

## LEVEL 3: Finding-by-finding / explanatory

**Clinical-biomarker correlations** (computed from `repro1012_full.csv`; EXPLORATORY):
- baseline within-DMN vs ΔZung, untreated (n = 14): Pearson r = +0.127, p = .666 (paper reported r = .63) → does not reproduce.
- Δwithin-DMN vs ΔMADRS, treated (n = 9): Pearson r = −0.413, p = .269 (paper reported r = −.734) → direction agrees, magnitude and significance do not; small n (winner's curse).

**Study 2 central finding (repro1012), against the paper's reported values:**
α1 untreated within-DMN (paper t = 2.21, p = .044); α2 combined DMN–ECN (paper t = −2.44, p = .030); α3 NFB DMN–ECN (paper t = −3.35, p = .020); β baseline within-DMN vs ΔZung (paper r = .63); γ Δwithin-DMN vs ΔMADRS (paper r = −.734). Note: the original IC12 was a hybrid DMN/LFr component, so the original "within-DMN" is not cleanly identical to the NeuroMark whole-DMN summary.

**Data-driven ICA (parcellation branch).** 20-component ICA. Spatial matching to NeuroMark and to Smith RSNs was uniformly weak (best |r| ≈ 0.01 at template-core voxels), and the provisional labels (e.g. IC06 → DMN) did not survive a stricter spatial match (best match became a cerebellar component). This exposes a component-correspondence problem rather than establishing component identity.
Group comparison on the data-driven decomposition (`check_dataica_fnc`, 51 depressed vs 21 control), VERIFIED:

Domain pairs (t, p, d): within-ECN 1.260, .212, .327; within-SAL 1.817, .0735, .471; DMN-ECN 0.342, .733, .089; DMN-SAL 0.244, .808, .063; ECN-SAL 0.749, .456, .194. All non-significant.

Connection-wise among the networks of interest (15 pairs): only IC14-IC18 reached nominal significance (t = 2.320, p = .0233, d = .601); 1/15 nominally significant (chance expectation ≈ 0.8); 0 survive Bonferroni (threshold p < .0033). The finding does not reappear under the original study's own data-driven method.

**Coarse domain-level analysis (Study 1)** (`check_domains`, 51 depressed vs 21 control), VERIFIED. Six domain relations (depressed mean, control mean, t, p, d, direction):

| Domain pair | depr | ctrl | t | p | d | direction |
|---|---|---|---|---|---|---|
| within-DMN | 0.0840 | 0.0768 | 0.447 | .6566 | 0.116 | depr > ctrl |
| within-ECN | 0.2786 | 0.2501 | 0.807 | .4225 | 0.209 | depr > ctrl |
| within-SAL | 0.4827 | 0.4562 | 0.768 | .4452 | 0.199 | depr > ctrl |
| DMN-ECN | 0.0032 | -0.0051 | 0.460 | .6468 | 0.119 | depr > ctrl |
| DMN-SAL | 0.1116 | 0.1034 | 0.422 | .6740 | 0.110 | depr > ctrl |
| ECN-SAL | -0.0879 | -0.0535 | -1.078 | .2847 | -0.280 | depr < ctrl |

0/6 significant uncorrected, 0/6 Bonferroni (threshold p < .0083), 0/6 FDR. Note the within-DMN direction is depressed > control here, opposite to the original's reported decrease, and non-significant.

---

## LEVEL 4: QC / statistical forensics

**Empirical permutation null (10,000 permutations, 52 triple-network edges).** Expected at alpha = .05: 2.60.
- Study 1: empirical mean 2.62, SD 2.04, binomial SD 1.57, dependence inflation 1.30×
- Study 2: empirical mean 2.63, SD 1.98, inflation 1.26×; 95th percentile of the null count = 6 (both).
- Native 52-edge empirical p: Study 1 found 1, p_emp = .8737; Study 2 found 3, p_emp = .4563.

**Chance / binomial audit of the original's reported counts** (arithmetic on the paper's numbers; no data).
- Study 1 group comparisons: 55 tests, expected 2.75, 7 reported, p = .0193 (dependence-corrected .0369).
- Study 2 dynamics: 312 tests, expected 15.60, 17 reported, p = .3934 (corrected .4263).
- Study 1 FC–ZSRDS: 5 tests, expected ≈ 0.2, 2 reported, p = .0226.
Bonferroni(55) = .00091; the paper's smallest Study 1 p (.004) would not survive.

**Spatial validation (Smith 2009 RSN templates, positive control).** Visual RSNs correctly hit visual NeuroMark components (r = .69, .67, .71). Triple-network DMN components match the Smith DMN template up to r = .61 (median .41); ECN components up to r = .50. Confirms the NeuroMark network identification is valid, while the data-driven components do not correspond cleanly (all r ≈ .01).

**Overlap / dependence.**
- NeuroMark 1.0 posterior-DMN strict sets are subsets of the broader sets (within 6/6, CC 68/68).
- v25 uses identical pairs and the same 72 scans as the primary analysis (Jaccard = 1.00; only the fMRIPrep version differs).
- Study 2 (n = 29) is a subset of the Study 1 depressed sample (57% overlap); the Study 2 PRE scans ARE the Study 1 scans for those patients.
- Verdict: the 13 direction comparisons are not 13 independent tests. **Report 3/7 with caveats; do NOT report 8/13 as an overall replication rate.**

---

## LEVEL 5: Superseded / invalid but historically real

Kept for provenance, never reported: 20-person pilot NBS; broader whole-network NBS;
old `nbs_work72_H1/H1_result.mat` (implementation with all-Inf test statistics, replaced
by the FIXED branch); old unadjusted TOST; residualisation (two-step) TOST; grid-based
Study 2 TOST (superseded by the exact TOST above); intermediate matching variants
(`match_v2`, superseded by `match_v3`).

---

## Verification status

All results in this file have now been verified from saved runtime output
(`study1_results.log`, `corrected_results_runtime.txt`, `tost_ancova_runtime.txt`,
`tost_study2_exact_runtime.txt`, `study2_final_missing_results.txt`,
`perm_null_runtime.txt`, `results_check_domains.txt`, `results_dataica_group.txt`),
or recomputed from the per-subject data (`repro1012_full.csv`). No values remain
outstanding.
