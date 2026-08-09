%% pair1012_study2.m
% Ερώτημα: αναπαράγεται το κεντρικό εύρημα "αποδιοργάνωσης" του paper
% (ζεύγος 10-12, within-DMN μείωση στην ομάδα NT);
%
% Α: paired t-test pre vs post, ΜΟΝΟ 15 NT (sub-01..15) — ίδιο μέτρο με paper (Table 6)
% Β: περιγραφικά, ΟΛΟΙ οι 29 — τι κάνει το ζεύγος συνολικά
%
% ΒΑΣΗ: DMN = TN-DM subdomain NeuroMark 2.2 = ICN 94-101 (επικυρωμένο, label file).
% ΟΡΙΟ (τεκμηριωμένο): το 2.2 ΔΕΝ διαχωρίζει anterior/posterior DMN
%   (centroids: όλα Y<0). Άρα "within-DMN" = ΟΛΟ το DMN subdomain, 28 ζεύγη.
% Τιμές = Fisher-z (fnc_corrs). Δz = post - pre.

clear; clc;
ROOT   = '.';
FNCDIR = fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
NSUB = 29;
DMN = 94:101; ECN = 91:93;

% φόρτωση 58 scans: index 2i-1 = sub-i pre, 2i = sub-i post
Z = nan(58,105,105);
for f = 1:58
    S = load(fullfile(FNCDIR, sprintf('nmark_s2_post_process_sub_%03d.mat', f)));
    Z(f,:,:) = squeeze(S.fnc_corrs);
end

% δείκτες ζευγών within-DMN (28) και DMN-ECN (24)
[di,dj] = find(triu(true(numel(DMN)),1));
wDMN = [DMN(di)' DMN(dj)'];                          % 28 x 2
[ei,ej] = ndgrid(DMN,ECN); DMNECN = [ei(:) ej(:)];   % 24 x 2

pre = squeeze(Z(1:2:end,:,:));   % 29 x 105 x 105  (pre)
post= squeeze(Z(2:2:end,:,:));   % 29 x 105 x 105  (post)

% μέσος όρος κάθε κατηγορίας ανά άτομο (pre, post, Δ)
avgpairs = @(M,P) mean(arrayfun(@(k) M(P(k,1),P(k,2)), 1:size(P,1)));
wpre=zeros(NSUB,1); wpost=zeros(NSUB,1); epre=zeros(NSUB,1); epost=zeros(NSUB,1);
for s=1:NSUB
    Ppre=squeeze(pre(s,:,:)); Ppost=squeeze(post(s,:,:));
    wpre(s)=avgpairs(Ppre,wDMN);  wpost(s)=avgpairs(Ppost,wDMN);
    epre(s)=avgpairs(Ppre,DMNECN); epost(s)=avgpairs(Ppost,DMNECN);
end
wD = wpost - wpre;   % Δz within-DMN ανά άτομο (μέσος 28 ζευγών)
eD = epost - epre;   % Δz DMN-ECN ανά άτομο (μέσος 24 ζευγών)

NT = 1:15;

fprintf('================ ΕΡΩΤΗΜΑ 10-12 (Study 2) ================\n');
fprintf('ΒΑΣΗ: NeuroMark 2.2, DMN=ICN94-101 (28 ζεύγη), DMN-ECN (24 ζεύγη)\n');
fprintf('Paper (Table 6): NT ζεύγος 10-12 within-DMN ΜΕΙΩΘΗΚΕ, t=2.21 p=.044 dz=+0.57\n\n');

%% ---- Α: ΑΝΑΠΑΡΑΓΩΓΗ (paired, 15 NT) ----
fprintf('--- Α: ΑΝΑΠΑΡΑΓΩΓΗ paper (paired t-test, 15 NT, sub-01..15) ---\n');
for lab_pair = {{'within-DMN', wD}, {'DMN-ECN', eD}}
    nm = lab_pair{1}{1}; d = lab_pair{1}{2}(NT);
    [~,p,ci,st] = ttest(d);
    dz = mean(d)/std(d);
    fprintf('%-10s: mean Δz=%+.4f  t(%d)=%+.2f  p=%.3f  95%%CI[%+.3f,%+.3f]  dz=%+.3f\n', ...
        nm, mean(d), st.df, st.tstat, p, ci(1), ci(2), dz);
end
fprintf('  Σημ.: το paper βρήκε ΜΕΙΩΣΗ within-DMN. Θετικό mean Δz εδώ = ΑΥΞΗΣΗ = αντίθετο.\n\n');

%% ---- Β: ΠΕΡΙΓΡΑΦΙΚΑ (29) ----
fprintf('--- Β: ΠΕΡΙΓΡΑΦΙΚΑ, ΟΛΟΙ οι 29 (όχι test έναντι paper) ---\n');
for lab_pair = {{'within-DMN', wD}, {'DMN-ECN', eD}}
    nm = lab_pair{1}{1}; d = lab_pair{1}{2};
    fprintf('%-10s: mean Δz=%+.4f  SD=%.4f  εύρος[%+.3f,%+.3f]  |Δz|>0.2: %d/29  αντίθετα πρόσημα: %d+/%d-\n', ...
        nm, mean(d), std(d), min(d), max(d), sum(abs(d)>0.2), sum(d>0), sum(d<0));
end

% σύγκριση διασποράς ανά άτομο vs μέση μετατόπιση (η κρίσιμη γραμμή)
fprintf('\n--- Το κρίσιμο: διασπορά vs σήμα ---\n');
fprintf('within-DMN: |μέση μετατόπιση 29| = %.4f  vs  SD μεταξύ ατόμων = %.4f  -> λόγος %.2f\n', ...
    abs(mean(wD)), std(wD), abs(mean(wD))/std(wD));
fprintf('DMN-ECN   : |μέση μετατόπιση 29| = %.4f  vs  SD μεταξύ ατόμων = %.4f  -> λόγος %.2f\n', ...
    abs(mean(eD)), std(eD), abs(mean(eD))/std(eD));
fprintf('(λόγος << 1 => η μετατόπιση πνίγεται στη διασπορά μεταξύ ατόμων)\n');

% αποθήκευση
T = table((1:NSUB)', wpre, wpost, wD, epre, epost, eD, ...
    'VariableNames', {'subject','wDMN_pre','wDMN_post','wDMN_delta', ...
                      'DMNECN_pre','DMNECN_post','DMNECN_delta'});
grp = repmat({'NT'},NSUB,1);
grp([16 17 18 19 20 23 24 25])={'CBT'}; grp([21 22 26 27 28 29])={'NFB'};
T.group = grp;
writetable(T, fullfile(ROOT,'pair1012_study2.csv'));
fprintf('\nΑρχείο: pair1012_study2.csv\n');
fprintf('ΟΡΙΟ 1: μέσος 28 ζευγών ΔΕΝ = το ένα ζεύγος 10-12 του paper (2.2 δεν διαχωρίζει posterior).\n');
fprintf('ΟΡΙΟ 2: Α=αναπαραγωγή (15 NT), Β=περιγραφή (29). ΜΟΝΟ το Α συγκρίνεται με τον ισχυρισμό.\n');
