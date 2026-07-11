import sys, pandas as pd, numpy as np
tsv = sys.argv[1]  # confounds file
df = pd.read_csv(tsv, sep="\t")
fd = df["framewise_displacement"].astype(float)
print(f"{np.nanmean(fd):.4f}")
