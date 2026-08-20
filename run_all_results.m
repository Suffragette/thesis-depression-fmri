function run_all_results()
% RUN_ALL_RESULTS  Runs the core analysis scripts and captures each script's
% console output into results/<name>.txt (via MATLAB diary), so the actual
% numerical results become inspectable in the repository without re-running.
%
% ---------------------------------------------------------------------------
% HOW TO RUN (on your Mac):
%   1. Open MATLAB. Set the Current Folder to the REPOSITORY ROOT
%      (the folder that contains code/, env/, results/ and your data folders
%       output72/, output_study2/, output_dataica20/ ...).
%   2. Edit MATLAB_ROOT below to your local toolbox path (GIFT/NeuroMark, NBS, SPM12).
%   3. In the Command Window type:   run_all_results
%
% Each script is independent (it does clear; clc at its top). This driver is a
% FUNCTION on purpose, so those clears cannot wipe the loop. Errors in one
% script do NOT stop the batch; they are logged to results/_ERRORS.txt.
%
% DATA NOTE: most scripts need the preprocessed FNC .mat files (present on your
% Mac, gitignored from the repo). chance_audit runs with NO data (pure
% arithmetic on the paper's own reported numbers).
%
% After it finishes: commit the results/*.txt files (they are plain text, NOT
% gitignored) so the numbers are visible in the repository.
% ---------------------------------------------------------------------------

clear; clc;
here = pwd;
if ~exist('results','dir'); mkdir('results'); end

% --- toolboxes (EDIT THIS LINE to your local path) --------------------------
MATLAB_ROOT = '<MATLAB_ROOT>';   % e.g. '/Users/you/MATLAB'
try
    addpath(genpath(fullfile(MATLAB_ROOT,'GIFT')));
    addpath(genpath(fullfile(MATLAB_ROOT,'NBS1.2')));
    addpath(genpath(fullfile(MATLAB_ROOT,'spm12')));
catch
    fprintf('(!) Could not add one or more toolboxes from MATLAB_ROOT; edit the path if scripts fail.\n');
end

% --- run list: {script path, output name, section, evidence type, what it shows} ---
JOBS = {
'code/04_statistics/run_cnbs_H1_triple.m', 'nbs_primary',            '3.1',      'Primary null test (FWER-controlled NBS)',        'Whether ANY connected subnetwork differs between depressed and controls over the triple-network. If none survives FWER, there is no group difference above the family-wise-error threshold.';
'code/04_statistics/check_domains.m',      'domain_level',           '3.1',      'Coarse-network null test (t-tests + Bonferroni/FDR)', 'Whether the coarse DMN/ECN/salience domain-pairs (the paper''s granularity) differ between groups after multiple-comparison correction.';
'code/04_statistics/chance_audit.m',       'chance_audit',           '3.1',      'Chance baseline (binomial; NO data needed)',     'Whether the number of "significant" findings the original reported exceeds what is expected by chance under no true effect and no correction.';
'code/04_statistics/perm_null.m',          'perm_null',              '3.1',      'Empirical permutation null (10,000 perms)',      'How many "significant" connections appear vs the chance expectation over the 52 triple-network edges, accounting for inter-edge dependence.';
'code/04_statistics/a3_direction.m',       'direction_pipelines',    '3.2-3.3',  'Sensitivity analysis (one-at-a-time)',           'Whether the DIRECTION of the within-DMN / DMN-ECN effect is stable across four reasonable pipelines. NOTE: examines stability across the tested pipelines; does not isolate the causal effect of each choice.';
'code/03_fnc/check_dataica_fnc.m',         'dataica_group',          '3.4',      'Sensitivity to parcellation (original''s own ICA)', 'Whether the findings reappear when the original study''s OWN data-driven decomposition (Infomax+ICASSO, 20 comp) is applied to the same data.';
'code/02_neuromark/match_to_neuromark.m',  'ica_matching',           '3.4',      'Spatial identification (spatial correlation)',   'Which of the 20 data-driven components correspond to DMN/ECN/salience, so the data-driven results can be compared to the atlas-based ones.';
'code/03_fnc/lagshift_study1.m',           'lagshift_metric',        '3.5',      'Sensitivity to the connectivity metric',         'Whether the group-level conclusion depends on zero-lag Pearson vs the original''s lag-shift (max-|r|) estimator, and quantifies the inflation from max-over-lags.';
'code/04_statistics/table3_full.m',        'table3_finding',         '3.6',      'Finding-by-finding (direction + significance)',  'For each of the original''s eight Table-3 connections, whether it reproduces in direction and in significance (only triple-network ones are testable).';
'code/04_statistics/clinical_corr.m',      'clinical_correlations',  '3.7',      'CORRELATION analysis (FC vs clinical change)',   'Whether the treatment-response correlations (original''s Tables 7-10) reproduce; includes a power reality-check flagging the "winner''s curse" from very small samples (n=4-6).';
'code/04_statistics/table6_full.m',        'table6_finding',         '3.8',      'Finding-by-finding (Study 2 dynamics)',          'How many of the original''s seventeen Table-6 treatment-related claims are testable in the triple-network scope, and whether those reproduce.';
'code/04_statistics/repro1012_full.m',     'repro_1012',             '3.8',      'Targeted reproduction (paired tests + corr)',    'Whether the original''s central Study-2 finding (the "10-12" connection) and its five sub-claims reproduce. Also writes repro1012_full.csv.';
'code/04_statistics/stats_study2.m',       'study2_longitudinal',    '3.8',      'Longitudinal pre-post (paired t, with CIs)',     'The pre-post connectivity changes for all four Study-2 groups, reported with confidence intervals (small n; not read as hypothesis tests). Also writes study2_delta_domain.mat.';
'code/04_statistics/outlier_audit.m',      'robustness_loo',         '3.9',      'Robustness (leave-one-out + data QC)',           'Whether the null result is driven by any single participant or by data-quality issues (leave-one-out on the two primary contrasts).';
'code/04_statistics/tost_peredge.m',       'tost_equivalence',       '3.10',     'Equivalence test (TOST, per connection)',        'For each connection, whether a difference as large as the one reported can be excluded, i.e. how much of the connectome the data can bound.';
};

errlog = fullfile('results','_ERRORS.txt');
if exist(errlog,'file'); delete(errlog); end
nOK = 0; nFail = 0;

for i = 1:size(JOBS,1)
    scriptPath = JOBS{i,1}; outName = JOBS{i,2}; sec = JOBS{i,3};
    etype = JOBS{i,4}; shows = JOBS{i,5};
    outFile = fullfile('results', [outName '.txt']);
    fprintf('\n[%d/%d] %-42s (section %s)\n', i, size(JOBS,1), scriptPath, sec);

    diary(outFile);
    fprintf('================================================================\n');
    fprintf('SCRIPT   : %s\n', scriptPath);
    fprintf('SECTION  : %s\n', sec);
    fprintf('TYPE     : %s\n', etype);
    fprintf('SHOWS    : %s\n', shows);
    fprintf('RUN AT   : %s\n', datestr(now));
    fprintf('================================================================\n\n');
    ok = runOne(scriptPath, errlog);
    diary off;
    cd(here);   % restore working dir in case a script changed it
    if ok; nOK = nOK + 1; else; nFail = nFail + 1; end
end

fprintf('\n================================================================\n');
fprintf('DONE. %d succeeded, %d failed.\n', nOK, nFail);
fprintf('Results in results/*.txt  (see results/_ERRORS.txt for any failures).\n');
fprintf('Commit the results/*.txt files so the numbers are visible in the repo.\n');
fprintf('================================================================\n');
end

function ok = runOne(scriptPath, errlog)
% Runs one script in an isolated workspace so its clear/clc cannot affect the
% driver. Captures errors instead of stopping the batch.
ok = true;
try
    run(scriptPath);
catch ME
    ok = false;
    fprintf('\n*** ERROR running %s:\n    %s\n', scriptPath, ME.message);
    fid = fopen(errlog, 'a');
    if fid > 0
        fprintf(fid, '%s : %s\n', scriptPath, ME.message);
        fclose(fid);
    end
end
end
