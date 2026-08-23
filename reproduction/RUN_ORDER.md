# Run order

How a third party reproduces the analysis from the openly available data. Paths use
two placeholders: a leading dot (`.`) is the repository/working directory, and
`<MATLAB_ROOT>` is the local path to the MATLAB toolboxes (GIFT/NeuroMark, NBS, SPM12).

## 1. Get the data
- Study 1: OpenNeuro ds002748 (https://openneuro.org/datasets/ds002748)
- Study 2: OpenNeuro ds003007 (https://openneuro.org/datasets/ds003007)
Raw data and derivatives are not stored in git (see `.gitignore`).

## 2. Preprocess and denoise (Python / Nilearn)
Run `code/01_preprocessing/`. Start from `denoise_V0_baseline.py`; the `V2`, `V5`,
`Vpaper` variants are the preprocessing-sensitivity branch. Batch drivers: `run_all_*.sh`.

## 3. Identify networks (MATLAB + GIFT/NeuroMark)
Run `code/02_neuromark/` for the NeuroMark 2.2 decomposition (and NM1.0 for the Study 2
sensitivity branch; data-driven ICA via `my_dataica_20.m`).

## 4. Compute connectivity (MATLAB)
The **primary FNC is produced by the NeuroMark postprocessing itself**: the
`code/02_neuromark/my_neuromark*.m` scripts run GIFT/NeuroMark and write per-subject
FNC into `*_post_process_sub_XXX.mat`. There is no separate `compute_fnc` script; all
downstream statistics read the FNC from those `.mat` files. `code/03_fnc/` holds the
alternative estimators used for sensitivity (`lagshift_study1.m`) and the data-driven
FNC comparison (`check_dataica_fnc.m`).

## 5. Statistics and export
With connectivity in place, run the statistics in `code/04_statistics/`. To capture
each script's output as text, wrap it in a MATLAB `diary`, for example:

    diary results/primary/study1/tost_ancova_runtime.txt
    tost_ancova
    diary off

Run headless from a terminal if preferred:

    matlab -batch "tost_ancova"

`chance_audit.m` needs no data and can be run on its own.

## 6. Toolboxes
See `env/versions.txt`. Required: GIFT/NeuroMark 2.2 (and 1.0 template), NBS 1.2,
SPM12, MATLAB (tested R2026a), Python 3.13 with nilearn 0.14.0 and nibabel 5.4.2.

## What you should get
Primary results are null or equivalence-bounded, not positive reproductions;
sensitivity branches change the analysis without restoring the original pattern. See
`results/RESULTS_GENEALOGY.md` for the verified outcome of every branch.
