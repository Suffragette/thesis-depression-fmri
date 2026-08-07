#!/bin/bash
set +e
FMRIPREP=~/ds002748-fmriprep
cd "$FMRIPREP"
OUT=~/thesis/derivatives/A3_V5_noBandpass; mkdir -p "$OUT"
for i in $(seq -w 1 72); do
  sub="sub-${i}"
  [ -f "$OUT/${sub}_clean_smooth.nii.gz" ] && continue
  bold="${sub}/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
  was_present=0; test -e "$bold" && was_present=1
  datalad get "$bold" \
    "${sub}/func/${sub}_task-rest_desc-confounds_timeseries.tsv" \
    "${sub}/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz" \
    || { echo "!!! $sub datalad FAILED"; continue; }
  python3 ~/thesis/code/01_preprocessing/denoise_V5_noBandpass.py "$sub" "$FMRIPREP" "$OUT" \
    || echo "  !!! $sub FAILED"
  [ "$was_present" -eq 0 ] && datalad drop "$bold" 2>/dev/null
done
echo "=== V5 DONE: $(ls $OUT/sub-*_clean_smooth.nii.gz 2>/dev/null | wc -l) / 72 ==="
