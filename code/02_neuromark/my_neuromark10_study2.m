%% GIFT Batch - Study 2 with NeuroMark 1.0 (53 ICNs)
% Purpose: 2.2 does not separate anterior/posterior DMN (centroids all Y<0).
% 1.0 has 7 DMN subnodes (2 ACC + 2 PCC + 3 PCu) = ICN 43-49 (Du et al. 2020).
modalityType = 'fMRI';
TR = 2.5;
outputDir = './output_study2_nm10';
prefix    = 'nmark10_s2';
dataSelectionMethod = 4;
input_data_file_patterns = cell(58,1);
for ii = 1:29
    input_data_file_patterns{2*ii-1} = sprintf('./data_study2/sub-%02d_ses-pre_clean_smooth.nii', ii);
    input_data_file_patterns{2*ii}   = sprintf('./data_study2/sub-%02d_ses-post_clean_smooth.nii', ii);
end
input_design_matrices = {};
dummy_scans = 0;
maskFile = './output_test/nmark2p2Mask.nii';
preproc_type = 1;
scaleType    = 2;
algoType     = 'moo-icar';
refFiles     = which('Neuromark_fMRI_1.0.nii');
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
    'SC', (1:5); 'AU', (6:7); 'SM', (8:16); 'VI', (17:25); ...
    'CC', (26:42); 'DM', (43:49); 'CB', (50:53) };
display_results.network_summary_opts.outputDir    = fullfile(outputDir, 'network_summary');
display_results.network_summary_opts.prefix       = [prefix, '_network_summary'];
display_results.network_summary_opts.structFile   = which('ch2bet_3x3x3.nii');
display_results.network_summary_opts.image_values = 'positive';
display_results.network_summary_opts.threshold    = 2;
display_results.network_summary_opts.convert_to_z = 'yes';
