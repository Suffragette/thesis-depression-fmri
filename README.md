# Reproducibility Reanalysis of Bezmaternykh et al. (2021)

Brain-network connectivity in mild-to-moderate depression — a reproducibility
reanalysis using **fMRIPrep** and **NeuroMark**, in place of the original
SPM12 + GIFT-ICA pipeline.

MSc thesis, Department of Computer Engineering and Informatics, University of Patras.

## Overview

This repository contains the analysis code for a reproducibility reanalysis of:

> Bezmaternykh, D. D., et al. (2021). Brain networks connectivity in mild to
> moderate depression: Resting state fMRI study with implications to
> nonpharmacological treatment. *Neural Plasticity*, 2021, 8846097.

Using the same openly available data but a modern, standardised pipeline and a
family-wise-error-controlled statistical test, the study re-examines whether the
original within-DMN and DMN–ECN connectivity findings reproduce. The main result
is that they do not reproduce at the reported magnitude or stability, and that
the non-reproduction cannot be attributed to any single methodological choice
(preprocessing, parcellation, connectivity metric, granularity, or outliers).

## Repository structure

- **`code/`** — analysis scripts.
  - Preprocessing (Python / Nilearn, run on Neurodesk): denoising variants
    (`V0` baseline, `V2` no-aCompCor, `V5` no-bandpass, `Vpaper` paper-matched).
  - Analysis (MATLAB, run locally): network identification (NeuroMark/GIFT),
    functional network connectivity, and statistics (NBS, permutation, TOST).
- **`env/`** — environment / dependency information.
- **`results/`** — key result files (summary outputs, not the large per-subject data).
- **`Appendix_Participant_Scan_Overlap.md`**, **`appendix_participant_overlap.csv`** —
  Study 2 participant-overlap audit.
- **`proposal.md`** — original thesis proposal.

## Data availability

The raw data are **not** stored here (they are large and already public). They are
available from OpenNeuro without restriction:

- Study 1 (intergroup): https://openneuro.org/datasets/ds002748
- Study 2 (dynamics): https://openneuro.org/datasets/ds003007

Because the data are public, the analysis is fully reproducible: download the
datasets and run the scripts in `code/`.

## Tools

- **fMRIPrep** — standardised preprocessing (Esteban et al., 2019)
- **NeuroMark 2.2 / GIFT** — network identification (Du et al., 2020)
- **NBS** — Network-Based Statistic, FWER-controlled (Zalesky et al., 2010)
- **Nilearn** — denoising / nuisance regression
- Languages: Python, MATLAB, Bash

## Author

Christina Kouimountzi — MSc thesis, University of Patras (2026).
Supervisor: Konstantinos Tsichlas.
