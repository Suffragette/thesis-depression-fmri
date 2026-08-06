%% STUDY 2 (ds003007): longitudinal FNC analysis
%  58 scans = 29 subjects x 2 sessions. File order from my_neuromark_study2.m:
%     index 2i-1 = sub-i ses-pre ,  index 2i = sub-i ses-post
%
%  Subgroups (from participants.tsv):
%     NT  (no treatment) : sub-01..15                      (n=15)
%     CBT (psychotherapy): sub-16,17,18,19,20,23,24,25     (n=8)
%     NFB (neurofeedback): sub-21,22,26,27,28,29           (n=6)
%
%  Analysis: paired t-test pre vs post on domain-level FNC, per subgroup.
%  NOTE ON POWER: n=6-15. These tests can only detect very large within-subject
%  effects. Results are reported with CIs and must not be read as hypothesis
%  tests. The original paper itself calls these small groups "a source of
%  false positives".
clear; clc;

PP    = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_study2/nmark_s2_postprocess_results';
nSub  = 29;
ECN   = 91:93; DMN = 94:101; SAL = 102:105;
ALPHA = 0.05;

NT  = 1:15;
CBT = [16 17 18 19 20 23 24 25];
NFB = [21 22 26 27 28 29];

%% ---- load 58 FNC matrices ----
FNC = nan(105,105,58);
for k = 1:58
    f = fullfile(PP, sprintf('nmark_s2_post_process_sub_%03d.mat', k));
    if ~exist(f,'file'), error('Missing: %s', f); end
    s = load(f);
    m = squeeze(s.fnc_corrs); m(isnan(m)) = 0;
    FNC(:,:,k) = m;
end
fprintf('Loaded 58 scans (29 subjects x 2 sessions)\n\n');

%% ---- domain-level score per scan ----
labels = {'within-DMN','within-ECN','within-SAL','DMN-ECN','DMN-SAL','ECN-SAL'};
defs   = {{DMN,DMN,1},{ECN,ECN,1},{SAL,SAL,1},{DMN,ECN,0},{DMN,SAL,0},{ECN,SAL,0}};

sc = nan(58, numel(defs));
for k = 1:58
    M = FNC(:,:,k);
    for c = 1:numel(defs)
        A = defs{c}{1}; B = defs{c}{2}; within = defs{c}{3};
        blk = M(A,B);
        if within
            msk = triu(true(numel(A)),1);
            sc(k,c) = mean(blk(msk));
        else
            sc(k,c) = mean(blk(:));
        end
    end
end

% reshape into pre/post per subject
PRE  = sc(1:2:end, :);   % 29 x 6
POST = sc(2:2:end, :);   % 29 x 6
DELTA = POST - PRE;      % positive = increase over time
save('/Users/hedylamarr/Documents/MATLAB/thesis_scripts/study2_delta_domain.mat','PRE','POST','DELTA','labels');

%% ---- paired tests per subgroup ----
groups = {NT,'no-treatment'; CBT,'CBT'; NFB,'neurofeedback'; 1:29,'ALL (pooled)'};

for g = 1:size(groups,1)
    idx = groups{g,1}; gname = groups{g,2}; n = numel(idx);
    fprintf('================ %s (n=%d) ================\n', gname, n);
    fprintf('%-12s %9s %9s %9s %8s %8s %19s\n', ...
            'contrast','pre','post','delta','t','p','dz [95%% CI]');
    for c = 1:numel(defs)
        d = DELTA(idx,c);
        d = d(~isnan(d));
        nn = numel(d);
        if nn < 3, fprintf('%-12s  (n<3, skipped)\n', labels{c}); continue; end
        md = mean(d); sd = std(d); se = sd/sqrt(nn);
        t  = md/se; nu = nn-1;
        p  = 2*(1 - tcdf(abs(t), nu));
        dz = md/sd;                              % paired effect size
        tc = tinv(1-ALPHA/2, nu);
        loCI = (md - tc*se)/sd; hiCI = (md + tc*se)/sd;
        star = ''; if p < ALPHA, star = ' *'; end
        fprintf('%-12s %9.4f %9.4f %+9.4f %8.3f %8.4f  %+.2f [%+.2f,%+.2f]%s\n', ...
                labels{c}, mean(PRE(idx,c)), mean(POST(idx,c)), md, t, p, dz, loCI, hiCI, star);
    end
    fprintf('\n');
end

fprintf(['REMINDER: with n=6-15, only |dz| well above ~1.0 is detectable.\n' ...
         'No multiple-comparison correction applied here (6 contrasts x 4 groups\n' ...
         '= 24 tests); any single p<0.05 is expected by chance (~1.2 of 24).\n' ...
         'Report CIs, not significance.\n\n' ...
         'Saved study2_delta_domain.mat -> feed into the clinical-correlation step.\n']);
