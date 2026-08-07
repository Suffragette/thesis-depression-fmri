#!/bin/bash
# Re-run ds002748 (Study 1, 72 subj) with fMRIPrep 25.2.5 + --fs-no-reconall
# -> harmonises Study 1 with Study 2 (identical version AND flags).
# Disk-safe: one subject at a time, cleanup after each.
# Graceful: if it doesn't finish, the completed subset serves as an ICC
#           sensitivity check against the old 21.0.2 derivative.
set -u
BIDS=~/thesis/ds002748
FMRIPREP=~/ds002748-fmriprep-v25
OUT=~/thesis/derivatives/clean_s1_v25
FDLOG=~/thesis/derivatives/design/mean_fd_s1_v25.tsv
WORK=~/fmriprep-work-s1
CONDA_PY=/opt/conda/bin/python3

mkdir -p "$OUT" "$(dirname "$FDLOG")" ~/freesurfer-subjects-dir "$WORK"
[ -f "$FDLOG" ] || echo -e "participant_id\tmean_fd" > "$FDLOG"

for n in $(seq -w 1 72); do
  sub="sub-$n"
  clean="$OUT/${sub}_clean_smooth.nii.gz"
  [ -f "$clean" ] && { echo ">>> $sub: done, skip"; continue; }
  [ -d "$BIDS/$sub" ] || { echo ">>> $sub: not in BIDS, skip"; continue; }

  echo "=================================================="
  echo ">>> $sub: fMRIPrep 25.2.5 starting ($(date +%d/%m\ %H:%M))..."
  # fetch raw for this subject only
  ( cd "$BIDS" && datalad get "$sub" ) || { echo "!!! $sub: datalad get failed"; continue; }

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
    || { echo "!!! $sub: fMRIPrep FAILED"; rm -rf "$WORK"/* 2>/dev/null; ml purge 2>/dev/null; continue; }

  ml purge 2>/dev/null
  bold="$FMRIPREP/$sub/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
  if [ -f "$bold" ]; then
    echo ">>> $sub: denoise..."
    $CONDA_PY ~/thesis/code/01_preprocessing/denoise_smooth.py "$sub" "$FMRIPREP" "$OUT" \
      || echo "!!! $sub: denoise FAILED"
    conf="$FMRIPREP/$sub/func/${sub}_task-rest_desc-confounds_timeseries.tsv"
    if [ -f "$conf" ] && ! grep -q "^${sub}"$'\t' "$FDLOG"; then
      fd=$($CONDA_PY ~/thesis/code/utils/mean_fd.py "$conf" 2>/dev/null)
      echo -e "${sub}\t${fd}" >> "$FDLOG"
    fi
  else
    echo "!!! $sub: no preproc_bold produced"
  fi

  echo ">>> $sub: cleanup..."
  rm -rf "$FMRIPREP/$sub" 2>/dev/null
  rm -rf "$WORK"/* 2>/dev/null
  ( cd "$BIDS" && datalad drop "$sub" 2>/dev/null )
  echo ">>> $sub: OK. $(date +%H:%M). Disk: $(df -h ~ | tail -1 | awk '{print $4}')"
done

echo "=== ΤΕΛΟΣ Study 1 v25 ==="
ls "$OUT"/*_clean_smooth.nii.gz 2>/dev/null | wc -l
echo "clean αρχεία (στόχος 72· >=15 αρκεί για ICC sensitivity check)"
