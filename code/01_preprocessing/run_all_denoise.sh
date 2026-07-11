#!/bin/bash
# Batch: κατεβάζει + κάνει denoise/smooth ΟΛΑ τα άτομα του ds002748-fmriprep
set -e
FMRIPREP=~/ds002748-fmriprep
OUT=~/thesis/derivatives/clean
mkdir -p "$OUT"

cd "$FMRIPREP"
# Βρες όλα τα διαθέσιμα subjects
SUBS=$(ls -d sub-* | grep -E '^sub-[0-9]+$')

for sub in $SUBS; do
  clean="$OUT/${sub}_clean_smooth.nii.gz"
  if [ -f "$clean" ]; then
    echo ">>> $sub: υπάρχει ήδη, skip"
    continue
  fi
  echo ">>> $sub: κατέβασμα..."
  datalad get -q \
    "$sub/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz" \
    "$sub/func/${sub}_task-rest_desc-confounds_timeseries.tsv" \
    "$sub/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz" \
    || { echo "!!! $sub: αποτυχία download, skip"; continue; }

  echo ">>> $sub: denoise + smooth..."
  python3 ~/thesis/code/01_preprocessing/denoise_smooth.py "$sub" "$FMRIPREP" "$OUT" \
    || { echo "!!! $sub: αποτυχία processing, skip"; continue; }
done

echo "=== ΟΛΟΚΛΗΡΩΘΗΚΕ ==="
ls -la "$OUT"/*_clean_smooth.nii.gz | wc -l
echo "clean αρχεία παραπάνω"
