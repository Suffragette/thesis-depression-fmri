%% STUDY 2: FULL DESCRIPTIVE REPORT, SUBJECT BY SUBJECT
%  No inference. Every number, every person. Evaluation comes after.
clear; clc;
D = '.';
load(fullfile(D,'study2_delta_domain.mat'));           % PRE POST DELTA labels (29 x 6)
cl = readtable(fullfile(D,'clinical_study2.tsv'),'FileType','text', ...
               'Delimiter','\t','TreatAsMissing',{'n/a'});
gname = string(cl.group);
gshort = strings(29,1);
gshort(gname=="depr_no_treatment") = "NT ";
gshort(gname=="depr_cbt")          = "CBT";
gshort(gname=="depr_nfb")          = "NFB";

gv = @(n) cl.(matlab.lang.makeValidName(n));
BDIp = gv('BDI_ses-pre');  BDIq = gv('BDI_ses-post');
ZUNp = gv('Zung_SDS_ses-pre'); ZUNq = gv('Zung_SDS_ses-post');
MADp = gv('MADRS_ses-pre'); MADq = gv('MADRS_ses-post');

%% ---------- TABLE 1: CLINICAL, PER SUBJECT ----------
fprintf('=============================================================================\n');
fprintf('TABLE 1. CLINICAL SCORES PER SUBJECT (pre -> post, change)\n');
fprintf('Negative change = improvement.  "." = not measured\n');
fprintf('=============================================================================\n');
fprintf('%-7s %-4s | %5s %5s %6s | %5s %5s %6s | %5s %5s %6s\n', ...
        'subj','grp','BDIp','BDIq','dBDI','ZUNp','ZUNq','dZUN','MADp','MADq','dMAD');
for i = 1:29
    f = @(v) fmt(v);
    fprintf('sub-%02d  %-4s | %5s %5s %6s | %5s %5s %6s | %5s %5s %6s\n', i, gshort(i), ...
        f(BDIp(i)), f(BDIq(i)), f(BDIq(i)-BDIp(i)), ...
        f(ZUNp(i)), f(ZUNq(i)), f(ZUNq(i)-ZUNp(i)), ...
        f(MADp(i)), f(MADq(i)), f(MADq(i)-MADp(i)));
end

%% ---------- TABLE 2: FNC CHANGE, PER SUBJECT ----------
fprintf('\n=============================================================================\n');
fprintf('TABLE 2. FNC CHANGE PER SUBJECT (post - pre), domain level\n');
fprintf('=============================================================================\n');
fprintf('%-7s %-4s', 'subj','grp');
short = {'wDMN','wECN','wSAL','D-E','D-S','E-S'};
for c=1:6, fprintf(' %8s', short{c}); end
fprintf('\n');
for i = 1:29
    fprintf('sub-%02d  %-4s', i, gshort(i));
    for c = 1:6, fprintf(' %+8.4f', DELTA(i,c)); end
    fprintf('\n');
end

%% ---------- TABLE 3: SUBGROUP SUMMARY ----------
fprintf('\n=============================================================================\n');
fprintf('TABLE 3. WHO IMPROVED CLINICALLY, WHO DID NOT\n');
fprintf('=============================================================================\n');
dB = BDIq-BDIp;
fprintf('%-7s %-4s %8s %-14s\n','subj','grp','dBDI','clinical');
for i = 1:29
    if isnan(dB(i)), lab = 'no BDI data';
    elseif dB(i) <= -5, lab = 'IMPROVED';
    elseif dB(i) >=  5, lab = 'WORSENED';
    else, lab = 'stable'; end
    fprintf('sub-%02d  %-4s %8s %-14s\n', i, gshort(i), fmt(dB(i)), lab);
end
nI = sum(dB<=-5); nW = sum(dB>=5); nS = sum(abs(dB)<5);
fprintf('\nImproved (dBDI<=-5): %d | Stable: %d | Worsened (>=+5): %d | No data: %d\n', ...
        nI, nS, nW, sum(isnan(dB)));

%% ---------- TABLE 4: DO THE TWO MOVE TOGETHER? ----------
fprintf('\n=============================================================================\n');
fprintf('TABLE 4. CLINICAL IMPROVERS vs NON-IMPROVERS: mean FNC change\n');
fprintf('(descriptive only; group sizes are small)\n');
fprintf('=============================================================================\n');
imp = dB <= -5; non = dB > -5 & ~isnan(dB);
fprintf('%-12s %10s %10s %10s\n','contrast', sprintf('IMPR(n=%d)',sum(imp)), ...
        sprintf('NON(n=%d)',sum(non)), 'diff');
for c = 1:6
    a = mean(DELTA(imp,c),'omitnan'); b = mean(DELTA(non,c),'omitnan');
    fprintf('%-12s %+10.4f %+10.4f %+10.4f\n', labels{c}, a, b, a-b);
end

fprintf('\n--- No p-values in this report by design. Inference is in stats_study2.m\n');
fprintf('--- and corr_qc_study2.m, where confidence intervals are given.\n');

function s = fmt(v)
    if isnan(v), s = '.'; else, s = sprintf('%+.0f', v); end
    if v >= 0 && ~isnan(v), s = sprintf('%.0f', v); end
end
