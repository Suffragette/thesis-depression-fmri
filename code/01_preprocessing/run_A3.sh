#!/bin/bash
# A3: run 3 denoising variants x 72 subjects (V0 already = existing clean)
FMRIPREP=~/ds002748-fmriprep
for VAR in V2_noCompCor V5_noBandpass Vpaper; do
  OUT=~/thesis/derivatives/A3_${VAR}
  mkdir -p "$OUT"
  echo "======== VARIANT $VAR -> $OUT ========"
  for i in $(seq -w 1 72); do
    sub="sub-${i}"
    out="$OUT/${sub}_clean_smooth.nii.gz"
    if [ -f "$out" ]; then echo "  $sub exists, skip"; continue; fi
    python3 denoise_${VAR}.py "$sub" "$FMRIPREP" "$OUT" \
      || echo "  !!! $sub FAILED in $VAR"
  done
done
echo "=== A3 DENOISE DONE ==="
for VAR in V2_noCompCor V5_noBandpass Vpaper; do
  n=$(ls ~/thesis/derivatives/A3_${VAR}/sub-*_clean_smooth.nii.gz 2>/dev/null | wc -l)
  echo "$VAR: $n / 72 files"
done
