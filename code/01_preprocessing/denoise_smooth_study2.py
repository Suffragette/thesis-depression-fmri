#!/usr/bin/env python3
"""Denoising + smoothing for Study 2 (ds003007) - handles sessions."""
import sys, os
from nilearn.image import clean_img, smooth_img
from nilearn.interfaces.fmriprep import load_confounds

sub, ses, FMRIPREP, OUT = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
os.makedirs(OUT, exist_ok=True)
base = f"{FMRIPREP}/{sub}/{ses}/func/{sub}_{ses}_task-rest"
bold = f"{base}_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
mask = f"{base}_space-MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz"
print(f"[{sub}_{ses}] loading confounds...", flush=True)
confounds, sample_mask = load_confounds(
    bold,
    strategy=("motion", "high_pass", "wm_csf", "scrub", "compcor"),
    motion="full", wm_csf="basic", compcor="anat_combined", n_compcor=5,
    scrub=5, fd_threshold=0.5, std_dvars_threshold=1.5,
)
print(f"[{sub}_{ses}] cleaning...", flush=True)
cleaned = clean_img(bold, confounds=confounds, mask_img=mask,
                    detrend=True, standardize="zscore_sample",
                    t_r=2.5, low_pass=0.15, high_pass=0.01)
print(f"[{sub}_{ses}] smoothing 8mm...", flush=True)
smoothed = smooth_img(cleaned, fwhm=8)
out = f"{OUT}/{sub}_{ses}_clean_smooth.nii.gz"
smoothed.to_filename(out)
print(f"[{sub}_{ses}] DONE -> {out}  shape={smoothed.shape}", flush=True)
