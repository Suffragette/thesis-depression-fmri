# Environment notes

Exact versions are in `versions.txt`. All versions were verified from the
fMRIPrep `dataset_description.json` files, run logs, and direct environment
queries, rather than from memory.

## Two-environment workflow
- **Preprocessing** (fMRIPrep + nilearn denoising) ran on **Neurodesk**, a
  containerised cloud platform accessed through the browser and authenticated
  via GitHub. Data were retrieved from OpenNeuro with DataLad in the Neurodesk
  terminal.
- **Analysis** (network definition, functional connectivity, NBS, TOST) ran
  **locally in MATLAB R2026a** on the author's workstation, on the cleaned
  derivatives transferred from Neurodesk.

## Preprocessing versions
- **Study 1 primary** used the public **fMRIPrep 21.0.2** derivatives distributed
  with ds002748 (not re-run from raw data).
- **Study 2** was preprocessed with **fMRIPrep 25.2.5** (ds003007).
- Because the two studies rested on different fMRIPrep versions, a matched
  **Study 1 v25** derivative was generated with **fMRIPrep 25.2.5**
  (`--fs-no-reconall`) as a preprocessing-sensitivity branch. This branch was
  **executed and reported for Study 1**; Study 2 was not re-run, as it was
  already preprocessed with 25.2.5.
- Denoising ran in **Python 3.13.14** (nilearn 0.14.0, nibabel 5.4.2) on Neurodesk.

## Network definition and analysis
- **NeuroMark 2.2** is the primary template (105 networks, modelorder-multi),
  used for both studies. **NeuroMark 1.0** is used only for the Study 2
  network-definition sensitivity branch (posterior/whole/anterior DMN).
- The **data-driven ICA** branch (Study 1 sensitivity) uses GIFT Infomax +
  ICASSO, 20 components.
- MATLAB analyses used GIFT/NeuroMark (MOO-ICAR), NBS toolbox 1.2, and SPM12
  (for template reslicing only).
- Triple-network component indices (NeuroMark 2.2): ECN 91-93, DMN 94-101,
  salience 102-105.
