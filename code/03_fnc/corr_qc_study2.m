%% STUDY 2: (a) motion QC, (b) correlations between FNC change and clinical change
%  Requires:
%    study2_delta_domain.mat  (from stats_study2.m)
%    clinical_study2.tsv      (copy of ds003007 participants.tsv)
%    mean_fd_study2.tsv       (participant_id / session / mean_fd)
clear; clc;
D = '.';

%% ================= (a) MOTION QC =================
fdF = fullfile(D,'mean_fd_study2.tsv');
if exist(fdF,'file')
    fd = readtable(fdF,'FileType','text','Delimiter','\t');
    fprintf('======== MOTION QC (Study 2) ========\n');
    fprintf('rows in FD log: %d (expected 58)\n', height(fd));
    v = fd.mean_fd;
    fprintf('mean FD across scans : %.4f (SD %.4f)\n', mean(v,'omitnan'), std(v,'omitnan'));
    fprintf('max  mean FD         : %.4f\n', max(v));
    [~,im] = max(v);
    fprintf('worst scan           : %s %s\n', string(fd{im,1}), string(fd{im,2}));
    nEx = sum(v > 0.5);
    fprintf('scans with mean FD>0.5 : %d  -> exclusions: %d\n', nEx, nEx);
    fprintf('(Study 1 for comparison: max mean FD 0.22, zero exclusions)\n\n');
else
    fprintf('!! mean_fd_study2.tsv not found - skipping QC\n\n');
end

%% ================= (b) CLINICAL CORRELATIONS =================
load(fullfile(D,'study2_delta_domain.mat'));   % PRE POST DELTA labels
cl = readtable(fullfile(D,'clinical_study2.tsv'),'FileType','text', ...
               'Delimiter','\t','TreatAsMissing',{'n/a','NA',''});

% subgroup codes
grpstr = string(cl.group);
sub_NT  = find(grpstr=="depr_no_treatment");
sub_CBT = find(grpstr=="depr_cbt");
sub_NFB = find(grpstr=="depr_nfb");
fprintf('Subgroups from tsv: NT=%d CBT=%d NFB=%d (expected 15/8/6)\n\n', ...
        numel(sub_NT), numel(sub_CBT), numel(sub_NFB));

% clinical change = post - pre  (negative = improvement)
getnum = @(t,name) t.(matlab.lang.makeValidName(name));
scores = {'MADRS','Zung_SDS','BDI'};
CH = nan(height(cl), numel(scores));
for s = 1:numel(scores)
    pre  = getnum(cl,[scores{s} '_ses-pre']);
    post = getnum(cl,[scores{s} '_ses-post']);
    CH(:,s) = post - pre;
    fprintf('%-9s complete pre+post pairs: %d/29\n', scores{s}, sum(~isnan(CH(:,s))));
end
fprintf('\n');

groups = {(1:29)','ALL'; sub_NT,'no-treatment'; sub_CBT,'CBT'; sub_NFB,'NFB'};

for g = 1:size(groups,1)
    idx = groups{g,1}; gname = groups{g,2};
    fprintf('================ %s ================\n', gname);
    fprintf('%-12s %-9s %5s %8s %8s %20s\n','FNC contrast','clinical','n','r','p','95%% CI');
    for c = 1:numel(labels)
        for s = 1:numel(scores)
            x = DELTA(idx,c); y = CH(idx,s);
            ok = ~isnan(x) & ~isnan(y);
            n = sum(ok);
            if n < 5
                fprintf('%-12s %-9s %5d   -- n<5, not computed --\n', labels{c}, scores{s}, n);
                continue;
            end
            [r,p] = corr(x(ok), y(ok), 'type','Pearson');
            % Fisher z CI
            z = atanh(r); se = 1/sqrt(n-3);
            lo = tanh(z - 1.96*se); hi = tanh(z + 1.96*se);
            star = ''; if p < 0.05, star = ' *'; end
            fprintf('%-12s %-9s %5d %+8.3f %8.4f  [%+.2f, %+.2f]%s\n', ...
                    labels{c}, scores{s}, n, r, p, lo, hi, star);
        end
    end
    fprintf('\n');
end

fprintf(['INTERPRETATION LIMITS\n' ...
         '  - %d contrasts x %d scales x %d groups = %d correlations, uncorrected.\n' ...
         '  - MADRS is available for only ~9/29 subjects, and only in treated groups.\n' ...
         '    Correlations on n<10 are not interpretable; the original paper reports\n' ...
         '    r values of +/-1.00 in its NFB tables, which is what happens at n~3-4.\n' ...
         '  - Report the CIs. A width of ~1.5 means the data are uninformative.\n'], ...
         numel(labels), numel(scores), size(groups,1), numel(labels)*numel(scores)*size(groups,1));
