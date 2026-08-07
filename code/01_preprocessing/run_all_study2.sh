#!/bin/bash
# Study 2 (ds003007): fMRIPrep -> denoise -> FD log -> cleanup, disk-safe.
set -u
BIDS=~/thesis/ds003007
FMRIPREP=~/ds003007-fmriprep
OUT=~/thesis/derivatives/clean_study2
FDLOG=~/thesis/derivatives/design/mean_fd_study2.tsv
WORK=~/fmriprep-work
CONDA_PY=/opt/conda/bin/python3

mkdir -p "$OUT" "$(dirname "$FDLOG")" ~/freesurfer-subjects-dir
[ -f "$FDLOG" ] || echo -e "participant_id\tsession\tmean_fd" > "$FDLOG"

for n in $(seq -w 1 29); do
  sub="sub-$n"
  if [ -f "$OUT/${sub}_ses-pre_clean_smooth.nii.gz" ] && [ -f "$OUT/${sub}_ses-post_clean_smooth.nii.gz" ]; then
    echo ">>> $sub: done, skip"; continue
  fi
  echo "=================================================="
  echo ">>> $sub: fMRIPrep starting ($(date +%H:%M))..."
  ml load fmriprep/25.2.5 2>/dev/null
  export SUBJECTS_DIR=~/freesurfer-subjects-dir
  fmriprep "$BIDS" "$FMRIPREP" participant \
    --participant-label "$n" \
    --fs-license-file ~/license.txt \
    --fs-no-reconall \
    --output-spaces MNI152NLin2009cAsym:res-2 \
    --nprocs 4 --mem-mb 12000 \
    --work-dir "$WORK" \
    --fs-subjects-dir ~/freesurfer-subjects-dir \
    --stop-on-first-crash \
    || { echo "!!! $sub: fMRIPrep FAILED, skip"; rm -rf "$WORK"/* 2>/dev/null; ml purge 2>/dev/null; continue; }
  ml purge 2>/dev/null
  for ses in ses-pre ses-post; do
    bold="$FMRIPREP/$sub/$ses/func/${sub}_${ses}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
    if [ -f "$bold" ]; then
      echo ">>> $sub $ses: denoise..."
      $CONDA_PY ~/thesis/code/01_preprocessing/denoise_smooth_study2.py "$sub" "$ses" "$FMRIPREP" "$OUT" \
        || echo "!!! $sub $ses: denoise FAILED"
      conf="$FMRIPREP/$sub/$ses/func/${sub}_${ses}_task-rest_desc-confounds_timeseries.tsv"
      if [ -f "$conf" ] && ! grep -q "^${sub}"$'\t'"${ses}"$'\t' "$FDLOG"; then
        fd=$($CONDA_PY ~/thesis/code/utils/mean_fd.py "$conf" 2>/dev/null)
        echo -e "${sub}\t${ses}\t${fd}" >> "$FDLOG"
      fi
    fi
  done
  echo ">>> $sub: cleanup..."
  rm -rf "$FMRIPREP/$sub" 2>/dev/null
  rm -rf "$WORK"/* 2>/dev/null
  echo ">>> $sub: OK. Disk:"; df -h ~ | tail -1
done
echo "=== ΤΕΛΟΣ ==="
ls "$OUT"/*_clean_smooth.nii.gz 2>/dev/null | wc -l
echo "clean αρχεία (στόχος: 58)"
