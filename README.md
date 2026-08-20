# A reanalysis of "Brain Networks Connectivity in Mild to Moderate Depression" (Bezmaternykh et al., 2021): reproducibility of resting-state functional connectivity findings using fMRIPrep and NeuroMark

MSc thesis reanalysing the openly available resting-state fMRI datasets ds002748 and ds003007 associated with Bezmaternykh et al. (2021), using alternative, explicitly documented analysis specifications.

MSc thesis, Department of Computer Engineering and Informatics, University of Patras.
Author: Christina Kouimountzi. Supervisor: Konstantinos Tsichlas.

## Overview

This repository contains the analysis code for a reanalysis of:

> Bezmaternykh, D. D., et al. (2021). Brain networks connectivity in mild to moderate depression: Resting state fMRI study with implications to nonpharmacological treatment. *Neural Plasticity*, 2021, 8846097.

The study examines whether the principal functional-connectivity conclusions reported by Bezmaternykh et al. remain supported when the same openly available data are analysed under alternative analysis specifications. Here "reproducibility" is used in this restricted sense — re-examination of the same data under different, explicitly documented analytical choices — not as independent-sample replication.

This is not a direct replication of the original workflow. Beyond a primary analysis, the project includes multiple targeted sensitivity and additional analyses: denoising variants, NeuroMark versus data-driven ICA, spatial matching, zero-lag versus lag-shift connectivity estimation, the Network-Based Statistic (NBS), equivalence (TOST) analyses, finding-by-finding comparisons, and Study 2 longitudinal analyses. These examine the influence of selected analytical choices where possible; they do not constitute a full multiverse analysis and do not isolate the causal effect of any individual choice.

## Scope and interpretation

- **Reanalysis, not replication.** The same openly available datasets are re-used; this is not an independent sample.
- **Prespecified, not preregistered.** The primary analysis was prespecified; it was not formally preregistered with a public timestamp.
- **Study 1 / Study 2 convergence.** A participant/scan-overlap audit (documented in `Appendix_Participant_Scan_Overlap.md` and `appendix_participant_overlap.csv`) indicates substantial overlap between the two datasets. This limits the interpretation of any cross-study convergence as *independent* evidence; it is not, in itself, a claim about the validity of the original study.

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
| my_dataica_20.m | Data-driven ICA following the original study's approach (Infomax+ICASSO, 20 comp) |
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
| run_cnbs_H1_triple.m | Confirmatory, prespecified triple-network NBS — standard NBS (Zalesky 2010), FWER | 3.1 |
| run_nbs_72.m, run_nbs.m | Supporting / pilot NBS | 3.1 |
| chance_audit.m | Are the paper's counts above chance? | 3.1 |
| perm_null.m | Empirical permutation null | 3.1 |
| check_domains.m | Domain-level comparison (granularity) | 3.1 |
| check_uncorrected.m | Uncorrected diagnostic | 3.1 |
| a3_direction.m | Direction of the effect across 4 pipelines | 3.2 |
| direction_audit.m | Whether sign agreement across pipelines exceeds 50% | 3.2 |
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

**Terminology note:** the confirmatory analysis uses the *standard* Network-Based Statistic (Zalesky et al., 2010). The "cnbs" in `run_cnbs_H1_triple.m` denotes "confirmatory NBS" (prespecified) and does **not** refer to constrained NBS (cNBS), which is a different method.

### Utils (MATLAB + Python)

Spatial matching (spatial_corr*.m, dmn_centroids*.m, postdmn_22.m, rsn_dmn_centroids.m), descriptive reports (describe_*.m, tag_paper_map_study2.m), and QC (mean_fd.py, qc_image.py).

## Tools

- fMRIPrep - standardised preprocessing (Esteban et al., 2019)
- NeuroMark 2.2 / GIFT - network identification (Du et al., 2020)
- NBS - Network-Based Statistic, FWER-controlled (Zalesky et al., 2010)
- Nilearn - denoising / nuisance regression
- Languages: Python, MATLAB, Bash

## How to reproduce

The full analysis runs in two environments: preprocessing in Python (Neurodesk), network identification and statistics in MATLAB.

1. **Get the data.** Download both datasets from OpenNeuro: ds002748 (Study 1) and ds003007 (Study 2).

2. **Preprocess** (Python / Neurodesk). Run fMRIPrep, then the denoising scripts in code/01_preprocessing/. The batch drivers handle all subjects:
   - run_all_denoise.sh (Study 1 baseline denoising)
   - run_A3.sh (the preprocessing variants V2 / V5 / Vpaper)
   - run_all_study2.sh (Study 2)

3. **Identify networks** (MATLAB + GIFT). Run the NeuroMark batch scripts in code/02_neuromark/ (e.g. my_neuromark_72.m), then compute functional network connectivity (code/03_fnc/).

4. **Run the statistics** (MATLAB). The scripts in code/04_statistics/ reproduce each result, e.g.:
   - run_cnbs_H1_triple.m - the confirmatory Network-Based Statistic (Section 3.1)
   - a3_direction.m - sign-stability across pipelines (Section 3.2)
   - lagshift_study1.m - connectivity-metric sensitivity (Section 3.5)
   - tost_peredge.m - equivalence testing (Section 3.10)

See the script inventory above for what each script does and which section it supports.

**Note on denoising variant numbering:** the variants are numbered V0 (baseline), V2 (no-aCompCor), V5 (no-bandpass), plus Vpaper (paper-matched). The intermediate numbers (V1, V3, V4) were design placeholders that were not implemented, since these four variants covered the preprocessing comparisons of interest.

## Setup notes (paths)

The scripts use **relative paths** and two placeholders, so no personal paths are hard-coded:

- **Data root** (`.`): scripts expect to be run **from the repository folder**, with the analysis outputs and inputs in the working directory. Run them after `cd` into the relevant `code/` subfolder, or adjust the `ROOT` variable at the top of each script to point to your local copy.
- **`<MATLAB_ROOT>`**: replace this with the path to your MATLAB toolboxes (GIFT/NeuroMark and SPM12). For example, on a typical install: `~/Documents/MATLAB`.
- **Data**: the fMRI datasets are not included (they are large and public). Download them from OpenNeuro (ds002748, ds003007) and point the scripts to your local copy.
