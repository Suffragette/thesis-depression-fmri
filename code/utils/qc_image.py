#!/usr/bin/env python3
"""Εικόνα ελέγχου: μέση εικόνα + μια φέτα, για οπτικό QC μετά το denoise/smooth."""
import sys
import matplotlib
matplotlib.use("Agg")   # χωρίς GUI, σώζει PNG
from nilearn import plotting, image

nii = sys.argv[1]           # το clean_smooth αρχείο
out = sys.argv[2]           # PNG output
mean = image.mean_img(nii)  # μέση εικόνα στον χρόνο
plotting.plot_epi(mean, title="Clean+Smooth (mean over time)",
                  display_mode="ortho", draw_cross=False, output_file=out)
print("saved:", out)
