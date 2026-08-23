# Study 1 / Study 2 overlap and dependence

This file documents an empirical finding about the datasets themselves, and explains
why it constrains interpretation. It is a statement about **evidential independence**,
not a claim about the validity of the original study.

## The finding

Using the openly available, de-identified data:

- The Study 2 sample (n = 29) is a **subset of the Study 1 depressed sample** (about
  57% overlap of the relevant subgroup).
- The Study 2 **pre-treatment scans are the Study 1 scans** for those participants.
- Within the NeuroMark 1.0 posterior-DMN analyses, the strict pair sets are exact
  subsets of the broader sets (within 6/6, cortico-cortical 68/68).
- The `v25` sensitivity branch uses the **same 72 scans** and the **same pairs** as the
  corresponding primary analysis (only the fMRIPrep version differs).

Sources: `overlap_audit.m`, `metadata/appendix_participant_overlap.csv`,
`metadata/Appendix_Participant_Scan_Overlap.md`, and
`results/audit/corrected_results_runtime.txt`.

## Why it matters (and why it does not)

**What it constrains.** Because Study 1 and Study 2 draw on overlapping participants
and scans, agreement between them is **not independent** confirmation. The 13 direction
comparisons across the project are therefore **not** 13 independent tests: v25 re-tests
Study 1 claims, NM1.0 re-tests Study 2 claims, and the primary analyses share networks
and subjects. The project reports **3/7 direction agreements with caveats** and does
**not** report an "8/13 replication rate", which would double-count dependent tests.

**What it does not mean.** This overlap is a property of how the public datasets are
constructed; it limits how *this reanalysis* may interpret cross-study convergence. It
is **not** evidence that the original study was wrong, and it is not presented as such.

## Two distinct "overlaps" (do not conflate)

- **Subgroup overlap (57%)** inside Study 2: the CBT and combined subgroups share
  participants, so the same patients are counted in more than one subgroup comparison
  (`overlap_audit.m`; the Study 2 subgroup analysis).
- **Cross-study overlap:** Study 2 participants/scans are drawn from Study 1
  (`metadata/Appendix_Participant_Scan_Overlap.md`). These are different facts and are
  documented separately.
