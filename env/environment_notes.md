# Environment notes

Exact versions are in `versions.txt`. Practical notes:

- **NeuroMark 2.2** is the primary template (105 networks, modelorder-multi). **NeuroMark 1.0** is used only for the Study 2 network-definition sensitivity branch.
- The **data-driven ICA** branch uses GIFT Infomax + ICASSO, 20 components.
- Preprocessing runs in a Python 3.13 environment (nilearn 0.14.0, nibabel 5.4.2), executed on Neurodesk.
- MATLAB analyses were run on R2026a with GIFT/NeuroMark, NBS 1.2, and SPM12 on the path (`<MATLAB_ROOT>`).
- Triple-network component indices (NeuroMark 2.2): ECN 91-93, DMN 94-101, salience 102-105.
