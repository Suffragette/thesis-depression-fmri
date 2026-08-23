# Deviations from the original study

This is the bridge between the original paper and this reanalysis. For each place
where a different reasonable choice was available, it records: the original choice,
our choice, the reason, the consequence for comparability, and the sensitivity
analysis that tests the deviation.

The point is not that our choices are "better". It is that each is explicit and each
is checked, so that any difference in results can be examined rather than assumed.

## 1. Preprocessing

- **Original:** SPM12-based preprocessing.
- **Ours:** fMRIPrep derivatives + Nilearn denoising (24 motion parameters, aCompCor, WM/CSF, scrubbing FD > 0.5, band-pass 0.01-0.15 Hz, 8 mm smoothing).
- **Reason:** a standardised, widely audited pipeline with explicit confound handling.
- **Comparability consequence:** different nuisance model; connectivity magnitudes are not directly comparable to the original.
- **Sensitivity:** `denoise_V2` (no aCompCor), `denoise_Vpaper` (motion-only, paper-matched), `v25` (alternative version). See `results/sensitivity/`.
- **Caveat:** the Nilearn `sample_mask` was not visibly passed into `clean_img`, so "scrubbing" means confound generation, not temporal censoring.

## 2. Network identification

- **Original:** data-driven group ICA (Infomax + ICASSO), with manual component identification.
- **Ours:** NeuroMark 2.2 spatially-constrained ICA (fixed 105-network template); triple-network subset ECN 91-93, DMN 94-101, salience 102-105.
- **Reason:** a fixed template makes networks directly comparable across subjects and datasets without a separate per-sample decomposition, and removes manual selection.
- **Comparability consequence:** components are defined by template, not by the sample; the original's hybrid components (e.g. IC12 DMN/LFr) have no exact NeuroMark twin.
- **Sensitivity:** the original's own data-driven ICA (`my_dataica_20.m`, `check_dataica_fnc.m`) and NeuroMark 1.0 (`my_neuromark10_study2.m`). Under the original's own ICA, the finding still did not survive correction; under NM1.0, some Study 2 directions changed while significance did not.

## 3. Connectivity estimation

- **Original:** correlation-based FNC (with the original's lag handling).
- **Ours:** zero-lag Fisher-z correlation as primary.
- **Reason:** zero-lag is the standard, transparent estimator.
- **Comparability consequence:** if the original used a lag-tolerant maximum, magnitudes inflate relative to zero-lag.
- **Sensitivity:** `lagshift_study1.m` (max-over-lags). Lag-shift inflates mean |r| by about 23% but does not restore the group effect.

## 4. Statistical inference

- **Original:** pairwise tests, reported largely uncorrected.
- **Ours:** confirmatory FWER-controlled NBS; targeted ANCOVA (age, sex, motion); FDR; and equivalence testing (TOST).
- **Reason:** control of false positives, and the ability to state when an effect of the reported size can be excluded rather than merely "not found".
- **Comparability consequence:** a finding significant only when uncorrected will not survive here; this is the intended, disclosed difference.
- **Sensitivity/QC:** permutation null (`perm_null.m`), chance audit (`chance_audit.m`), per-edge TOST, leave-one-out.

## 5. Granularity

- **Original:** specific connection-level findings and a coarse network reading.
- **Ours:** both domain-level (`check_domains.m`) and per-edge (`tost_peredge.m`) analyses, plus a dilution audit showing how a single-edge change (e.g. 0.140) shrinks to about 0.005 when averaged over 28 edges.
- **Reason:** to separate a genuine single-edge effect from a domain-mean estimand.
- **Sensitivity:** edge-level TOST branches; see `results/sensitivity/edge_level/`.

See `results/RESULTS_GENEALOGY.md` for the verified outcome of each branch, and
`docs/00_original_paper_workflow.md` for the workflow trees.
