%% GIFT Batch — Study 1 v25 (SENSITIVITY: --fs-no-reconall, εναρμονισμένο με Study 2)
% ΠΑΝΟΜΟΙΟΤΥΠΟ με my_neuromark_72.m. Αλλάζουν ΜΟΝΟ: input paths, outputDir, prefix.
modalityType = 'fMRI';
TR = 2.5;

outputDir = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output72_v25';
prefix    = 'nmark72v25';

dataSelectionMethod = 4;

% 72 άτομα, ΙΔΙΑ ΣΕΙΡΑ με my_neuromark_72.m (1-51 depressed, 52-72 controls)
input_data_file_patterns = cell(72,1);
for ii = 1:72
    input_data_file_patterns{ii} = sprintf( ...
      '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/data72_v25/sub-%02d_clean_smooth.nii', ii);
end

input_design_matrices = {};
dummy_scans = 0;

maskFile = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_test/nmark2p2Mask.nii';

preproc_type = 1;
scaleType    = 2;
algoType     = 'moo-icar';
refFiles     = which('Neuromark_fMRI_2.2_modelorder-multi.nii');

perfType = 1;
parallel_info.mode        = 'serial';
parallel_info.num_workers = 4;

display_results.formatName         = 'html';
display_results.slices_in_mm       = (-40:4:72);
display_results.convert_to_zscores = 'yes';
display_results.threshold          = 1.0;
display_results.image_values       = 'positive';
display_results.slice_plane        = 'axial';
display_results.anatomical_file    = which('ch2bet_3x3x3.nii');

display_results.network_summary_opts = struct();
display_results.network_summary_opts.comp_network_names = { ...
    'CB',    (1:13); 'VI-OT', (14:19); 'VI-OC', (20:25); 'PL', (26:36); ...
    'SC-EH', (37:39); 'SC-ET', (40:45); 'SC-BG', (46:54); 'SM', (55:68); ...
    'HC-IT', (69:75); 'HC-TP', (76:80); 'HC-FR', (81:90); ...
    'TN-CE', (91:93); 'TN-DM', (94:101); 'TN-SA', (102:105) };
display_results.network_summary_opts.outputDir    = fullfile(outputDir, 'network_summary');
display_results.network_summary_opts.prefix       = [prefix, '_network_summary'];
display_results.network_summary_opts.structFile   = which('ch2bet_3x3x3.nii');
display_results.network_summary_opts.image_values = 'positive';
display_results.network_summary_opts.threshold    = 2;
display_results.network_summary_opts.convert_to_z = 'yes';
