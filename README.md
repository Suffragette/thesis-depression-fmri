# Reproducibility Reanalysis of Bezmaternykh et al. (2021)

Brain-network connectivity in mild-to-moderate depression — a reproducibility reanalysis using **fMRIPrep** and **NeuroMark**, in place of the original SPM12 + GIFT-ICA pipeline.

MSc thesis, Department of Computer Engineering and Informatics, University of Patras.
Author: Christina Kouimountzi. Supervisor: Konstantinos Tsichlas.

## Overview

This repository contains the analysis code for a reproducibility reanalysis of:

> Bezmaternykh, D. D., et al. (2021). Brain networks connectivity in mild to moderate depression: Resting state fMRI study with implications to nonpharmacological treatment. *Neural Plasticity*, 2021, 8846097.

Using the same openly available data but a modern, standardised pipeline and a family-wise-error-controlled statistical test, the study re-examines whether the original within-DMN and DMN-ECN connectivity findings reproduce. **They do not reproduce** at the reported magnitude or stability, and the non-reproduction cannot be attributed to any single methodological choice.

## Pipeline

**Python (preprocessing, Neurodesk) -> MATLAB/GIFT (networks) -> MATLAB (statistics)**

Two computing environments: Neurodesk (Python/bash, fMRIPrep) and macOS (MATLAB, GIFT/NeuroMark, NBS).

## Data availability

Raw data are not stored here (large, already public). Available from OpenNeuro:
- Study 1 (intergroup): https://openneuro.org/datasets/ds002748
- Study 2 (dynamics): https://openneuro.org/datasets/ds003007

## Repository structure

    code/
      01_preprocessing/  Python (Nilearn) denoising + bash batch drivers
      02_neuromark/      Network identification (GIFT/NeuroMark)
      03_fnc/            Functional network connectivity
      04_statistics/     NBS, permutation, TOST, robustness
      utils/             Spatial matching, descriptive, QC
    env/                 Software versions
    results/             Key result files

## Script inventory

### Preprocessing - denoising (Python/Nilearn)

| Script | What it does |
|---|---|
| denoise_V0_baseline.py | Baseline: aCompCor + motion + FD scrub + band-pass + 8mm smooth |
| denoise_V2_noCompCor.py | Baseline minus aCompCor and WM/CSF regressors |
| denoise_V5_noBandpass.py | Baseline minus band-pass (full spectrum) |
| denoise_Vpaper.py | Paper-matched: motion only |
| denoise_smooth.py | Core denoise+smooth (Study 1) |
| denoise_smooth_study2.py | Denoise+smooth (Study 2, handles sessions) |

### Preprocessing - batch drivers (Bash)

| Script | What it does |
|---|---|
| run_all_denoise.sh, run_all_72.sh | Batch denoise all 72 subjects (Study 1) + FD log + cleanup |
| run_A3.sh, run_A3_fixed.sh | Run the 3 denoising variants x 72 subjects |
| run_V5only.sh | V5 (no-bandpass) variant only |
| run_study1_v25.sh | Re-run Study 1 with fMRIPrep 25.2.5 (harmonise with Study 2) |
| run_all_study2.sh, run_missing_study2.sh | Study 2 preprocessing (disk-safe) |

### Network identification (MATLAB + GIFT/NeuroMark)

| Script | What it does |
|---|---|
| my_neuromark_72.m | NeuroMark 2.2 baseline, 72 subjects (main) |
| my_neuromark_72_v25.m | NeuroMark v2.5 template (sensitivity) |
| my_neuromark_V2.m, my_neuromark_Vpaper.m | NeuroMark on V2 / Vpaper denoising |
| my_dataica_20.m | Data-driven ICA replicating the original (Infomax+ICASSO, 20 comp) |
| check_graymatter.m | Gray-matter component filtering (paper method) |
| match_to_neuromark.m, match_v2.m, match_v3.m | Spatial matching of ICs to templates |
| my_neuromark_study2.m, my_neuromark10_study2.m | NeuroMark 2.2 / 1.0 for Study 2 |

### Functional connectivity (MATLAB)

| Script | What it does |
|---|---|
| check_dataica_fnc.m | FNC group comparison on data-driven ICs |
| lagshift_study1.m | Zero-lag vs lag-shift connectivity metric (section 3.5) |
| perconn_study2.m, corr_qc_study2.m | Study 2 connection-level changes + QC |

### Statistics (MATLAB)

| Script | What it does | Thesis |
|---|---|---|
| run_cnbs_H1_triple.m | Confirmatory triple-network NBS (FWER) | 3.1 |
| run_cnbs_72.m, run_cnbs.m | Supporting / pilot NBS | 3.1 |
| chance_audit.m | Are the paper's counts above chance? | 3.1 |
| perm_null.m | Empirical permutation null | 3.1 |
| check_domains.m | Domain-level comparison (granularity) | 3.1 |
| check_uncorrected.m | Uncorrected diagnostic | 3.1 |
| a3_direction.m | Sign stability across 4 pipelines | 3.2 |
| direction_audit.m | Does sign agreement exceed 50%? | 3.2 |
| table3_full.m, table3_full_v25.m | Finding-by-finding, paper Table 3 | 3.6 |
| clinical_corr.m | Biomarker claim (paper Tables 7-10) | 3.7 |
| outlier_audit.m | Leave-one-out robustness | 3.9 |
| tost_peredge.m, tost_peredge_v25.m | Per-edge equivalence testing | 3.10 |
| tost_ancova.m | Covariate-adjusted TOST | 3.10 |
| sesoi_check.m | Lakens SESOI check | 3.10 |
| stats_study2.m | Study 2 longitudinal analysis | 3.8 |
| repro1012_full.m, pair1012_study2.m | Central "10-12" finding | 3.8 |
| table6_full.m | Finding-by-finding, paper Table 6 | 3.8 |
| overlap_audit.m | Subgroup overlap (57%) | 3.8 |
| tost_study2.m | Equivalence testing, Study 2 | 3.8 |

(Intermediate TOST versions - tost_study1*.m, tost_perpair.m - are kept for transparency of the analysis history.)

### Utils (MATLAB + Python)

Spatial matching (spatial_corr*.m, dmn_centroids*.m, postdmn_22.m, rsn_dmn_centroids.m), descriptive reports (describe_*.m, tag_paper_map_study2.m), and QC (mean_fd.py, qc_image.py).

## Tools

- fMRIPrep - standardised preprocessing (Esteban et al., 2019)
- NeuroMark 2.2 / GIFT - network identification (Du et al., 2020)
- NBS - Network-Based Statistic, FWER-controlled (Zalesky et al., 2010)
- Nilearn - denoising / nuisance regression
- Languages: Python, MATLAB, Bash
