#!/bin/bash
# Batch preprocessing ΟΛΩΝ των 72 ατόμων ds002748 (skip όσα υπάρχουν) + FD log + cleanup
FMRIPREP=~/ds002748-fmriprep
OUT=~/thesis/derivatives/clean
FDLOG=~/thesis/derivatives/design/mean_fd_all72.tsv
mkdir -p "$OUT" "$(dirname "$FDLOG")"
[ -f "$FDLOG" ] || echo -e "participant_id\tmean_fd" > "$FDLOG"

cd "$FMRIPREP"
for n in $(seq -w 1 72); do
  sub="sub-$n"
  clean="$OUT/${sub}_clean_smooth.nii.gz"
  # skip αν υπάρχει ήδη
  if [ -f "$clean" ]; then echo ">>> $sub: υπάρχει, skip"; continue; fi
  # skip αν δεν υπάρχει ο φάκελος (π.χ. κενά νούμερα)
  [ -d "$sub/func" ] || { echo ">>> $sub: δεν υπάρχει, skip"; continue; }

  echo ">>> $sub: download..."
  datalad get "$sub"/func/*MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz \
              "$sub"/func/*desc-confounds_timeseries.tsv \
              "$sub"/func/*MNI152NLin2009cAsym_res-2_desc-brain_mask.nii.gz \
    || { echo "!!! $sub: download fail"; continue; }

  echo ">>> $sub: denoise+smooth..."
  python3 ~/thesis/code/01_preprocessing/denoise_smooth.py "$sub" "$FMRIPREP" "$OUT" \
    || { echo "!!! $sub: processing fail"; continue; }

  # FD log (μόνο αν δεν υπάρχει ήδη η γραμμή)
  if ! grep -q "^${sub}\b" "$FDLOG"; then
    conf="$sub/func/${sub}_task-rest_desc-confounds_timeseries.tsv"
    fd=$(python3 ~/thesis/code/utils/mean_fd.py "$conf" 2>/dev/null)
    echo -e "${sub}\t${fd}" >> "$FDLOG"
  fi

  # cleanup: άδειασε τα βαριά raw για να μη γεμίσει ο δίσκος
  datalad drop "$sub"/func/*MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz 2>/dev/null

  echo ">>> $sub: OK"
done

echo "=== ΤΕΛΟΣ ==="
ls "$OUT"/*_clean_smooth.nii.gz | wc -l
echo "clean αρχεία σύνολο (στόχος: 72)"
