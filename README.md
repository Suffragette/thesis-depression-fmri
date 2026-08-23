# A reanalysis of "Brain Networks Connectivity in Mild to Moderate Depression" (Bezmaternykh et al., 2021)

Reproducibility of resting-state functional-connectivity findings, reanalysed on the
same openly available data (`ds002748`, `ds003007`) under alternative, explicitly
documented analytical specifications, using fMRIPrep and NeuroMark.

MSc thesis, Department of Computer Engineering and Informatics, University of Patras.

## Overview

This repository is the full record of a **same-data reproducibility reanalysis**. It
asks whether the principal connectivity conclusions of the original study remain
supported when the same data are analysed with a standardised pipeline and
error-controlled inference. It is **not** an independent-sample replication. It covers
both the original Study 1 (cross-sectional, depression vs controls) and Study 2
(longitudinal, treatment-related change).

```
Original paper
      |
Reproduction targets
      |
Same open datasets
      |
Alternative, standardised pipeline (fMRIPrep, NeuroMark 2.2)
      |
Primary reanalysis  ->  where a finding did not reproduce, targeted sensitivity branches
      |
Integrated, precision-aware interpretation
```

## The original study (reproduction targets)

Bezmaternykh et al. (2021), *Neural Plasticity*, 2021, 8846097
(https://doi.org/10.1155/2021/8846097). Study 1 reported altered within-DMN and
DMN-ECN connectivity in depression; Study 2 reported treatment-related dynamics.

## How this repository is organised

| Folder | What it holds |
|---|---|
| `docs/` | The research logic, provenance, and interpretation (start here). |
| `code/` | Executable analyses, organised by computational stage. |
| `env/` | Software and environment. |
| `metadata/` | Participant and QC metadata (no raw imaging data). |
| `results/` | Exported results, organised by evidential status. |
| `figures/`, `tables/` | Curated figures and tables. |
| `reproduction/` | Execution order, expected outputs, result manifest. |
| `thesis/`, `references/` | Thesis text and bibliography. |

**The organising rule:** code is arranged by *computational stage*
(`01_preprocessing` -> `02_neuromark` -> `03_fnc` -> `04_statistics` -> `utils`),
never by evidential status. Results are arranged by *evidential status*
(`primary`, `sensitivity`, `qc`, `audit`, `exploratory`, `superseded`). The mapping
between them, and the status of every analysis, lives in `docs/`.

## Where to look for what

- Why each decision was made: `docs/` (especially `04_deviations_from_original.md` and `08_computational_pipeline.md`).
- What each analysis is and its status: `docs/02_analysis_map.md`, `docs/03_analysis_status.md`.
- What exactly came out, with sources: `results/RESULTS_GENEALOGY.md`.
- How a third party reruns it: `reproduction/RUN_ORDER.md`.

## Important interpretive notes

- Reproducibility here means re-examination of the **same data**, not independent replication.
- Study 1 and Study 2 samples overlap substantially (see `docs/07_study_overlap.md`); cross-study convergence is not independent evidence.
- Sensitivity branches examine selected choices; they do not isolate the causal effect of any single choice.
- Non-significance is not evidence of no effect; equivalence tests report effects as *excluded* or *unresolved*.
- The confirmatory analysis uses the standard Network-Based Statistic (Zalesky 2010); "cnbs" in a filename means "confirmatory", not constrained NBS.

## Data availability

The original datasets are openly available on OpenNeuro: `ds002748` (Study 1) and
`ds003007` (Study 2). Raw imaging and large derivatives are **not** stored here
(see `.gitignore`); `reproduction/RUN_ORDER.md` explains how to obtain and process them.

## Citation and license

See `CITATION.cff` and `LICENSE`.
