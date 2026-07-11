#!/usr/bin/env python3
"""Denoising (aCompCor + motion + FD scrubbing) + smoothing 8mm.
Παίρνει fMRIPrep preprocessed bold -> βγάζει καθαρό, smoothed NIfTI για GIFT/NeuroMark.
Usage: python3 denoise_smooth.py <sub-id> <fmriprep_dir> <out_dir>
"""
import sys, os
from nilearn.image import clean_img, smooth_img
from nilearn.interfaces.fmriprep import load_confounds

sub, FMRIPREP, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(OUT, exist_ok=True)

bold = f"{FMRIPREP}/{sub}/func/{sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
mask = f"{FMRIPREP}/{sub}/func/{sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz"

print(f"[{sub}] loading confounds...", flush=True)
# Στρατηγική: motion(24p) + aCompCor + high-pass + scrubbing FD>0.5
confounds, sample_mask = load_confounds(
    bold,
    strategy=("motion", "high_pass", "wm_csf", "scrub", "compcor"),
    motion="full", wm_csf="basic", compcor="anat_combined", n_compcor=5,
    scrub=5, fd_threshold=0.5, std_dvars_threshold=1.5,
)

print(f"[{sub}] cleaning (denoise)...", flush=True)
cleaned = clean_img(bold, confounds=confounds, mask_img=mask,
                    detrend=True, standardize="zscore_sample",
                    t_r=2.5, low_pass=0.15, high_pass=0.01)

print(f"[{sub}] smoothing 8mm...", flush=True)
smoothed = smooth_img(cleaned, fwhm=8)

out = f"{OUT}/{sub}_clean_smooth.nii.gz"
smoothed.to_filename(out)
print(f"[{sub}] DONE -> {out}  shape={smoothed.shape}", flush=True)
