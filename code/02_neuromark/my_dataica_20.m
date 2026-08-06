%% Data-driven Group ICA, 20 components - PAPER-STYLE REPRODUCTION
%  Mimics Bezmaternykh 2021: Infomax + ICASSO, 20 comps, then GM filtering + FNC.
%  72 subjects (51 depr + 21 control). Contrast: our own tools, paper's method.

modalityType = 'fMRI';

%% ICASSO for stability (paper used ICASSO)
which_analysis = 2;
icasso_opts.sel_mode = 'randinit';
icasso_opts.num_ica_runs = 10;
icasso_opts.min_cluster_size = 2;
icasso_opts.max_cluster_size = 15;

%% TR
TR = 2.5;

group_ica_type = 'spatial';

parallel_info.mode = 'serial';
parallel_info.num_workers = 4;

perfType = 1;
conserve_disk_space = 0;

keyword_designMatrix = 'no';

dataSelectionMethod = 4;

input_data_file_patterns = {
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-01_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-02_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-03_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-04_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-05_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-06_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-07_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-08_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-09_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-10_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-11_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-12_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-13_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-14_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-15_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-16_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-17_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-18_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-19_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-20_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-21_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-22_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-23_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-24_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-25_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-26_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-27_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-28_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-29_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-30_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-31_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-32_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-33_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-34_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-35_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-36_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-37_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-38_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-39_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-40_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-41_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-42_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-43_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-44_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-45_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-46_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-47_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-48_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-49_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-50_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-51_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-52_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-53_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-54_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-55_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-56_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-57_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-58_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-59_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-60_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-61_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-62_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-63_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-64_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-65_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-66_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-67_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-68_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-69_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-70_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-71_clean_smooth.nii';
    '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72/sub-72_clean_smooth.nii'
};

input_design_matrices = {};
dummy_scans = 0;

%% Output
outputDir = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_dataica20';
prefix = 'dataica20';

%% Mask (reuse working mask)
maskFile = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_test/nmark2p2Mask.nii';

group_pca_type = 'subject specific';
backReconType = 4;
preproc_type = 3;
numReductionSteps = 2;

%% Fix 20 components (like paper), no auto-estimation
doEstimation = 0;
estimation_opts.PC1 = 'max';
estimation_opts.PC2 = 'mean';
numOfPC1 = 40;
numOfPC2 = 20;

%% Scale to z-scores (needed for later GM/WM/CSF spatial correlation)
scaleType = 2;

%% Infomax (like paper)
algoType = 1;

%% Report
display_results.formatName = 'html';
display_results.slices_in_mm = (-40:4:72);
display_results.convert_to_zscores = 'yes';
display_results.threshold = 1.0;
display_results.image_values = 'positive and negative';
display_results.slice_plane = 'axial';
display_results.anatomical_file = '/Users/hedylamarr/Documents/MATLAB/GIFT/gift-master/GroupICAT/icatb/icatb_templates/ch2bet_3x3x3.nii';

icaOptions = {'posact', 'off', 'sphering', 'on', 'bias', 'on', 'extended', 0};
