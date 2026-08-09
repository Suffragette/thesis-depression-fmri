%% GIFT Batch Template (generic)
% Fill in the USER SETTINGS section, then run:
%   icatb_batch_file_run('input_this_file.m');
% Date 2/10/2026

%% -----------------------------
% USER SETTINGS
% -----------------------------

% Modality: 'fMRI', 'sMRI', or 'EEG'
modalityType = 'fMRI';

% TR in seconds (scalar or 1 x nSubjects vector)
TR = 2.5;

% Output
outputDir = './output72_V2';
prefix    = 'nmark72_V2';

% Data selection method (1/2/3/4). This template uses Method 4.
dataSelectionMethod = 4;

% Method 4: list subject files (rows = subjects, cols = sessions)
% Example: 2 subjects, 1 session
input_data_file_patterns = {
    './data72_V2/sub-01_clean_smooth.nii'
    './data72_V2/sub-02_clean_smooth.nii'
    './data72_V2/sub-03_clean_smooth.nii'
    './data72_V2/sub-04_clean_smooth.nii'
    './data72_V2/sub-05_clean_smooth.nii'
    './data72_V2/sub-06_clean_smooth.nii'
    './data72_V2/sub-07_clean_smooth.nii'
    './data72_V2/sub-08_clean_smooth.nii'
    './data72_V2/sub-09_clean_smooth.nii'
    './data72_V2/sub-10_clean_smooth.nii'
    './data72_V2/sub-11_clean_smooth.nii'
    './data72_V2/sub-12_clean_smooth.nii'
    './data72_V2/sub-13_clean_smooth.nii'
    './data72_V2/sub-14_clean_smooth.nii'
    './data72_V2/sub-15_clean_smooth.nii'
    './data72_V2/sub-16_clean_smooth.nii'
    './data72_V2/sub-17_clean_smooth.nii'
    './data72_V2/sub-18_clean_smooth.nii'
    './data72_V2/sub-19_clean_smooth.nii'
    './data72_V2/sub-20_clean_smooth.nii'
    './data72_V2/sub-21_clean_smooth.nii'
    './data72_V2/sub-22_clean_smooth.nii'
    './data72_V2/sub-23_clean_smooth.nii'
    './data72_V2/sub-24_clean_smooth.nii'
    './data72_V2/sub-25_clean_smooth.nii'
    './data72_V2/sub-26_clean_smooth.nii'
    './data72_V2/sub-27_clean_smooth.nii'
    './data72_V2/sub-28_clean_smooth.nii'
    './data72_V2/sub-29_clean_smooth.nii'
    './data72_V2/sub-30_clean_smooth.nii'
    './data72_V2/sub-31_clean_smooth.nii'
    './data72_V2/sub-32_clean_smooth.nii'
    './data72_V2/sub-33_clean_smooth.nii'
    './data72_V2/sub-34_clean_smooth.nii'
    './data72_V2/sub-35_clean_smooth.nii'
    './data72_V2/sub-36_clean_smooth.nii'
    './data72_V2/sub-37_clean_smooth.nii'
    './data72_V2/sub-38_clean_smooth.nii'
    './data72_V2/sub-39_clean_smooth.nii'
    './data72_V2/sub-40_clean_smooth.nii'
    './data72_V2/sub-41_clean_smooth.nii'
    './data72_V2/sub-42_clean_smooth.nii'
    './data72_V2/sub-43_clean_smooth.nii'
    './data72_V2/sub-44_clean_smooth.nii'
    './data72_V2/sub-45_clean_smooth.nii'
    './data72_V2/sub-46_clean_smooth.nii'
    './data72_V2/sub-47_clean_smooth.nii'
    './data72_V2/sub-48_clean_smooth.nii'
    './data72_V2/sub-49_clean_smooth.nii'
    './data72_V2/sub-50_clean_smooth.nii'
    './data72_V2/sub-51_clean_smooth.nii'
    './data72_V2/sub-52_clean_smooth.nii'
    './data72_V2/sub-53_clean_smooth.nii'
    './data72_V2/sub-54_clean_smooth.nii'
    './data72_V2/sub-55_clean_smooth.nii'
    './data72_V2/sub-56_clean_smooth.nii'
    './data72_V2/sub-57_clean_smooth.nii'
    './data72_V2/sub-58_clean_smooth.nii'
    './data72_V2/sub-59_clean_smooth.nii'
    './data72_V2/sub-60_clean_smooth.nii'
    './data72_V2/sub-61_clean_smooth.nii'
    './data72_V2/sub-62_clean_smooth.nii'
    './data72_V2/sub-63_clean_smooth.nii'
    './data72_V2/sub-64_clean_smooth.nii'
    './data72_V2/sub-65_clean_smooth.nii'
    './data72_V2/sub-66_clean_smooth.nii'
    './data72_V2/sub-67_clean_smooth.nii'
    './data72_V2/sub-68_clean_smooth.nii'
    './data72_V2/sub-69_clean_smooth.nii'
    './data72_V2/sub-70_clean_smooth.nii'
    './data72_V2/sub-71_clean_smooth.nii'
    './data72_V2/sub-72_clean_smooth.nii'
};

% Optional: per-subject design matrices (only used for certain keyword_designMatrix settings)
% for each subject i.e., if you have selected 'diff_sub_diff_sess' for variable keyword_designMatrix.
input_design_matrices = {};

% Dummy scans to drop
dummy_scans = 0;

% Mask: [] for default, or full path, or special strings (if your lab uses them)
maskFile = './output_test/nmark2p2Mask.nii';  % or [] / 'C:\path\mask.nii'

% Preprocessing:
% 1 Remove mean per time point
% 2 Remove mean per voxel
% 3 Intensity normalization
% 4 Variance normalization
preproc_type = 1;

% Scaling:
% 0 none, 1 percent signal change, 2 Z-scores
scaleType = 2;

% ICA algorithm (string name or numeric, depending on your GIFT version)
% Examples: 'infomax', 'fastica', 'moo-icar', ...
algoType = 'moo-icar';

% Spatial reference template for constrained / Neuromark-style ICA
% (only used by certain algorithms like 'moo-icar' / constrained spatial ICA)
% fMRI templates: Neuromark_fMRI_1.0.nii, Neuromark_fMRI_2.0_modelorder-175.nii,
%   Neuromark_fMRI_2.0_modelorder-25.nii, Neuromark_fMRI_2.1_modelorder-multi.nii,
%   Neuromark_fMRI_2.2_modelorder-multi.nii, Neuromark_fMRI_3.0_aging_modelorder-100.nii
%   Neuromark_fMRI_3.0_development_modelorder-100.nii, Neuromark_fMRI_3.0_infant_modelorder-100.nii
%   Neuromark_fMRI_WM_2.2_modelorder-multi.nii
% Templates for sMRI Neuromark: Neuromark_sMRI_1.0_modelorder-30_2x2x2.nii
%   Neuromark_sMRI_3.0_modelorder-100_3x3x3.nii, Neuromark_dMRI_3.0_modelorder-100_3x3x3.nii
%   Neuromark_PET-FBP_1.0_modelorder-40_2x2x2.nii
refFiles = which('Neuromark_fMRI_2.2_modelorder-multi.nii');

%% -----------------------------
% PERFORMANCE / PARALLEL SETTINGS
% -----------------------------

% Performance type:
% 1 Maximize performance
% 2 Less memory usage
% 3 User specified settings
perfType = 1;

% Parallel execution
% mode: 'serial' or 'parallel'
parallel_info.mode        = 'serial';
parallel_info.num_workers = 4;

%% -----------------------------
% REPORT / DISPLAY SETTINGS  (fmri and smri only)
% -----------------------------

display_results.formatName        = 'html';
display_results.slices_in_mm      = (-40:4:72);
display_results.convert_to_zscores = 'yes';
display_results.threshold         = 1.0;
display_results.image_values      = 'positive';
display_results.slice_plane       = 'axial';
display_results.anatomical_file   = which('ch2bet_3x3x3.nii');

%% Network summary (fMRI; especially useful with Neuromark templates)
display_results.network_summary_opts = struct();
display_results.network_summary_opts.comp_network_names = { ...
    'CB',    (1:13); ...
    'VI-OT', (14:19); ...
    'VI-OC', (20:25); ...
    'PL',    (26:36); ...
    'SC-EH', (37:39); ...
    'SC-ET', (40:45); ...
    'SC-BG', (46:54); ...
    'SM',    (55:68); ...
    'HC-IT', (69:75); ...
    'HC-TP', (76:80); ...
    'HC-FR', (81:90); ...
    'TN-CE', (91:93); ...
    'TN-DM', (94:101); ...
    'TN-SA', (102:105) ...
};
display_results.network_summary_opts.outputDir     = fullfile(outputDir, 'network_summary');
display_results.network_summary_opts.prefix        = [prefix, '_network_summary'];
display_results.network_summary_opts.structFile    = which('ch2bet_3x3x3.nii');
display_results.network_summary_opts.image_values  = 'positive';
display_results.network_summary_opts.threshold     = 2;
display_results.network_summary_opts.convert_to_z  = 'yes';

  % Other network summary options
%display_results.network_summary_opts.conn_threshold = 0.2;
%display_results.network_summary_opts.fnc_colorbar_label = 'Corr';
%options are 'slices' and 'render'
%display_results.network_summary_opts.display_type = 'slices';
%display_results.network_summary_opts.slice_plane = 'axial';
%colormap of the correlations
%display_results.network_summary_opts.cmap = jet(64);
%CLIM - range of the data values in [min_value, max_value] format

%display_results.network_summary_opts.CLIM=CLIM;

