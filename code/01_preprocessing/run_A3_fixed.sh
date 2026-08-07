#!/bin/bash
set +e
FMRIPREP=~/ds002748-fmriprep
cd "$FMRIPREP"

for i in $(seq -w 1 72); do
  sub="sub-${i}"
  need=0
  for VAR in V2_noCompCor V5_noBandpass Vpaper; do
    [ -f ~/thesis/derivatives/A3_${VAR}/${sub}_clean_smooth.nii.gz ] || need=1
  done
  if [ "$need" -eq 0 ]; then echo ">>> $sub: all 3 exist, skip"; continue; fi

  bold="${sub}/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz"
  was_present=0
  test -e "$bold" && was_present=1

  echo ">>> $sub: datalad get..."
  datalad get "$bold" \
    "${sub}/func/${sub}_task-rest_desc-confounds_timeseries.tsv" \
    "${sub}/func/${sub}_task-rest_space-MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz" \
    || { echo "!!! $sub datalad FAILED"; continue; }

  for VAR in V2_noCompCor V5_noBandpass Vpaper; do
    OUT=~/thesis/derivatives/A3_${VAR}; mkdir -p "$OUT"
    [ -f "$OUT/${sub}_clean_smooth.nii.gz" ] && { echo "  $sub $VAR exists"; continue; }
    python3 ~/thesis/code/01_preprocessing/denoise_${VAR}.py "$sub" "$FMRIPREP" "$OUT" \
      || echo "  !!! $sub FAILED in $VAR"
  done

  # χωροδιαχειριση: αν το bold ΔΕΝ ηταν present πριν (το κατεβασαμε εμεις), σβησ'το
  if [ "$was_present" -eq 0 ]; then
    datalad drop "$bold" 2>/dev/null && echo "  $sub: dropped bold (freed space)"
  fi
done
echo "=== DONE ==="
for VAR in V2_noCompCor V5_noBandpass Vpaper; do
  echo "$VAR: $(ls ~/thesis/derivatives/A3_${VAR}/sub-*_clean_smooth.nii.gz 2>/dev/null | wc -l) / 72"
done
