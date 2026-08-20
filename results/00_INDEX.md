# Results index

This folder contains the console output of the core analysis scripts, captured
as plain text by `run_all_results.m` (run from the repository root). Each file is
the actual output of one script. The table below maps every file to the part of
the study it belongs to, the type of evidence it provides, and what it shows.

A note on interpretation, kept deliberately careful: these analyses examine
whether the original findings are **reproduced at the reported magnitude and
stability** under alternative, explicitly documented analytical choices. The
sensitivity analyses vary one choice at a time; they do **not** constitute a full
factorial/multiverse design and do **not** isolate the causal effect of any
individual choice.

| File | Section | Type of evidence | What it shows |
|---|---|---|---|
| `nbs_primary.txt` | 3.1 | Primary null test (FWER-controlled NBS) | Whether any connected subnetwork differs between depressed and controls over the triple-network. |
| `domain_level.txt` | 3.1 | Coarse-network null test (t-tests + Bonferroni/FDR) | Whether the coarse DMN/ECN/salience domain-pairs differ between groups after correction. |
| `chance_audit.txt` | 3.1 | Chance baseline (binomial; needs no data) | Whether the original's reported "significant" counts exceed what is expected by chance under no correction. |
| `perm_null.txt` | 3.1 | Empirical permutation null (10,000 perms) | How many "significant" connections appear vs the chance expectation, accounting for inter-edge dependence. |
| `direction_pipelines.txt` | 3.2–3.3 | Sensitivity analysis (one-at-a-time) | Whether the direction of the within-DMN / DMN–ECN effect is stable across four reasonable pipelines. |
| `dataica_group.txt` | 3.4 | Sensitivity to parcellation (original's own ICA) | Whether the findings reappear under the original's own data-driven decomposition (Infomax+ICASSO, 20 comp). |
| `ica_matching.txt` | 3.4 | Spatial identification (spatial correlation) | Which data-driven components correspond to DMN/ECN/salience, enabling comparison. |
| `lagshift_metric.txt` | 3.5 | Sensitivity to the connectivity metric | Whether the conclusion depends on zero-lag vs lag-shift (max-\|r\|) estimation; quantifies the inflation from max-over-lags. |
| `table3_finding.txt` | 3.6 | Finding-by-finding (direction + significance) | For each of the original's eight Table-3 connections, whether it reproduces in direction and significance. |
| `clinical_correlations.txt` | 3.7 | **Correlation analysis** (FC vs clinical change) | Whether the treatment-response correlations (Tables 7–10) reproduce; flags the "winner's curse" from very small samples (n=4–6). |
| `table6_finding.txt` | 3.8 | Finding-by-finding (Study 2 dynamics) | How many of the seventeen Table-6 treatment-related claims are testable, and whether those reproduce. |
| `repro_1012.txt` | 3.8 | Targeted reproduction (paired tests + correlation) | Whether the central Study-2 finding (the "10-12" connection) and its five sub-claims reproduce. |
| `study2_longitudinal.txt` | 3.8 | Longitudinal pre–post (paired t, with CIs) | Pre-post connectivity changes for all four Study-2 groups, with confidence intervals (small n). |
| `robustness_loo.txt` | 3.9 | Robustness (leave-one-out + data QC) | Whether the null result is driven by any single participant or by data-quality issues. |
| `tost_equivalence.txt` | 3.10 | Equivalence test (TOST, per connection) | For each connection, whether a difference as large as the one reported can be excluded (how much of the connectome the data can bound). |

`_ERRORS.txt` (if present) lists any script that failed to run and why.
