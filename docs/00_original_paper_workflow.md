# The original study, and where this reanalysis diverges

This file shows, first, what Bezmaternykh et al. (2021) actually did, and then
exactly where the present reanalysis attaches to their workflow and where it makes a
different, documented choice. Each deviation is the root of a sensitivity branch, so
an evaluator can see what changed, why, and which analysis tests that change.

See `01_research_path.md` for the full detail of this project's own path, and
`02_analysis_map.md` for the script-by-script mapping.

## 1. The original study's workflow

```
BEZMATERNYKH et al. (2021)
│
├── STUDY 1: CROSS-SECTIONAL
│   │
│   ├── Resting-state fMRI
│   │
│   ├── Preprocessing
│   │
│   ├── Data-driven ICA
│   │   └── subject/group components
│   │
│   ├── Component identification
│   │   ├── DMN-related components
│   │   ├── ECN-related components
│   │   └── other RSNs
│   │
│   ├── Functional connectivity between IC time courses
│   │
│   ├── Pairwise group comparisons
│   │
│   ├── Reported principal findings
│   │   ├── lower connectivity between DMN components 1–16
│   │   └── higher connectivity for component pair 11–13
│   │       interpreted in relation to DMN–ECN coupling
│   │
│   ├── Multiple pairwise tests
│   │   └── reported findings were uncorrected
│   │
│   └── Clinical correlation analyses
│
└── STUDY 2: LONGITUDINAL
    │
    ├── Resting-state fMRI
    │   ├── pre
    │   └── post
    │
    ├── Data-driven ICA
    │
    ├── Component identification
    │   └── imperfect correspondence with Study 1 components
    │
    ├── Functional connectivity
    │
    ├── Longitudinal subgroup analyses
    │   ├── untreated
    │   ├── combined treatment
    │   └── neurofeedback
    │
    ├── Principal reported findings
    │   ├── untreated:
    │   │   within-DMN decrease
    │   │
    │   ├── combined treatment:
    │   │   DMN–ECN increase
    │   │
    │   └── neurofeedback:
    │       DMN–ECN increase
    │
    └── Clinical-change correlations
```

## 2. Where this reanalysis attaches

```
ORIGINAL PAPER NODE
        │
        ▼
Can we recreate the same scientific question?
        │
        ├── exact component match possible?
        │       ├── yes → direct/close comparison
        │       └── no  → functional analogue
        │
        ▼
OUR PRIMARY REANALYSIS
fMRIPrep
   ↓
Nilearn denoising
   ↓
NeuroMark 2.2
   ↓
matched network/domain representation
   ↓
FNC
   ↓
primary tests
   ↓
NBS + ANCOVA + TOST
   ↓
Study 2 longitudinal tests
```

## 3. Each deviation generates a sensitivity branch

```
Original paper
│
├── data-driven ICA
│      ↓
│   ours: NeuroMark
│      ↓
│   sensitivity:
│   data-driven ICA + spatial matching
│
├── original connectivity estimator
│      ↓
│   ours: zero-lag
│      ↓
│   sensitivity:
│   lag-shift
│
├── original preprocessing
│      ↓
│   ours: fMRIPrep + Nilearn
│      ↓
│   sensitivity:
│   Vpaper / V2 / V5 / v25
│
├── original pairwise uncorrected inference
│      ↓
│   ours:
│   NBS / FDR / ANCOVA / TOST
│
└── original component-specific effects
       ↓
    ours:
    broader NeuroMark domain mappings
       ↓
    sensitivity:
    posterior DMN / NM1.0 / edge-level analysis
```

Read together: the primary reanalysis follows the same scientific questions as the
original, using a standardised, fixed-template representation (NeuroMark 2.2) and
error-controlled inference; each place where a different reasonable choice was
available became a sensitivity branch rather than a silent decision.
