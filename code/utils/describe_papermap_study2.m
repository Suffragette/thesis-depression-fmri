%% describe_papermap_study2.m
% ΑΝΑ ΑΤΟΜΟ: μεταβολές FNC με ΟΝΟΜΑΣΤΙΚΗ αντιστοίχιση προς
% Bezmaternykh et al. (2021), STUDY 2 ICA (Table 5: 17 comps, 13 GM-accepted).
% ΚΑΘΑΡΑ ΠΕΡΙΓΡΑΦΙΚΟ. Καμία δοκιμασία, καμία ερμηνεία.
% Αντιστοίχιση ΟΝΟΜΑΤΩΝ, ΟΧΙ χαρτών (χάρτες paper αδημοσίευτοι).
clear; clc;

ROOT   = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
FNCDIR = fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
NSUB = 29; THR = 0.5;

ECN=91:93; DMN=94:101; SAL=102:105; TN=[ECN DMN SAL];
groups = repmat({'NT'},1,NSUB);
groups([16 17 18 19 20 23 24 25]) = {'CBT'};
groups([21 22 26 27 28 29])       = {'NFB'};

lab = cell(1,105);
for k=ECN, lab{k}=sprintf('ECN%d',k); end
for k=DMN, lab{k}=sprintf('DMN%d',k); end
for k=SAL, lab{k}=sprintf('SAL%d',k); end

Z = nan(58,105,105);
for f=1:58
    S = load(fullfile(FNCDIR, sprintf('nmark_s2_post_process_sub_%03d.mat', f)));
    Z(f,:,:) = squeeze(S.fnc_corrs);
end

[ti,tj] = find(triu(true(15),1));
P = [TN(ti)' TN(tj)'];
inE=@(c)c>=91&c<=93; inD=@(c)c>=94&c<=101; inS=@(c)c>=102&c<=105;
cats = {'within-DMN','DMN-ECN','DMN-SAL','ECN-SAL','within-ECN','within-SAL'};
npair_paper = [3 3 0 0 0 0];   % ζεύγη διαθέσιμα στο paper (Table 5)
cid = zeros(105,1);
for p=1:105
    a=P(p,1); b=P(p,2);
    if inD(a)&&inD(b), cid(p)=1;
    elseif (inD(a)&&inE(b))||(inE(a)&&inD(b)), cid(p)=2;
    elseif (inD(a)&&inS(b))||(inS(a)&&inD(b)), cid(p)=3;
    elseif (inE(a)&&inS(b))||(inS(a)&&inE(b)), cid(p)=4;
    elseif inE(a)&&inE(b), cid(p)=5; else, cid(p)=6; end
end

% Ισχυρισμοί paper Table 6 αντιστοιχίσιμοι στα 105 ζεύγη.
% [within-DMN, DMN-ECN]: -1 = paper λέει ΜΕΙΩΣΗ, +1 = ΑΥΞΗΣΗ, 0 = κανένας ισχυρισμός
exp_map = containers.Map( {'NT','CBT','NFB'}, { [-1 0], [0 +1], [0 +1] } );
%  NT  : 10-12 within-DMN, dz=+0.57 -> ΜΕΙΩΣΗ
%  CBT : μόνο μέσω combined TR (11-16, dz=-0.65) -> ΑΥΞΗΣΗ. Το CBT-only ΔΕΝ το έδειξε.
%  NFB : 11-16 DMN-ECN, dz=-1.37 -> ΑΥΞΗΣΗ

fprintf('\n=== ΑΝΑ ΑΤΟΜΟ: Δz ανά κατηγορία + ισχυρισμός paper Study 2 ===\n');
R = nan(NSUB,10);
for s=1:NSUB
    D = squeeze(Z(2*s,:,:)) - squeeze(Z(2*s-1,:,:));
    d = D(sub2ind([105 105], P(:,1), P(:,2)));
    g = groups{s}; e = exp_map(g);
    m1 = d(cid==1); m2 = d(cid==2); mo = d(cid>=3);

    fprintf('\nsub-%02d (%s)\n', s, g);
    for c = 1:2
        v = d(cid==c);
        fprintf('  %-11s (%2d ζεύγη | paper: %d): mean Δz %+.3f  SD %.3f  εύρος [%+.3f,%+.3f]  >%.1f: %d\n', ...
            cats{c}, numel(v), npair_paper(c), mean(v), std(v), min(v), max(v), THR, sum(abs(v)>THR));
        hit = find(cid==c & abs(d)>THR);
        for h = hit'
            fprintf('      %s-%s  %+.3f\n', lab{P(h,1)}, lab{P(h,2)}, d(h));
        end
    end
    fprintf('  ΜΗ ΑΝΤΙΣΤΟΙΧΙΣΙΜΑ (paper: 0 salience comps, 1 ECN comp): %d ζεύγη, mean Δz %+.3f, >%.1f: %d\n', ...
        numel(mo), mean(mo), THR, sum(abs(mo)>THR));

    txt = 'κανένας ισχυρισμός σε TN χώρο';
    match = NaN;
    if e(1)~=0
        match = double(sign(mean(m1))==e(1));
        txt = sprintf('within-DMN %s -> άτομο %+.3f -> %s', ...
              ternary(e(1)<0,'ΜΕΙΩΣΗ','ΑΥΞΗΣΗ'), mean(m1), ternary(match==1,'ΙΔΙΑ ΚΑΤΕΥΘ.','ΑΝΤΙΘΕΤΗ'));
    elseif e(2)~=0
        match = double(sign(mean(m2))==e(2));
        txt = sprintf('DMN-ECN %s -> άτομο %+.3f -> %s', ...
              ternary(e(2)<0,'ΜΕΙΩΣΗ','ΑΥΞΗΣΗ'), mean(m2), ternary(match==1,'ΙΔΙΑ ΚΑΤΕΥΘ.','ΑΝΤΙΘΕΤΗ'));
    end
    fprintf('  Paper: %s\n', txt);
    R(s,:) = [s, mean(m1), std(m1), sum(abs(m1)>THR), mean(m2), std(m2), sum(abs(m2)>THR), ...
              mean(mo), sum(abs(mo)>THR), match];
end

fprintf('\n=== ΣΥΝΟΨΗ ΚΑΤΕΥΘΥΝΣΗΣ (περιγραφική· τύχη = 50%%) ===\n');
for g = {'NT','CBT','NFB'}
    m = strcmp(groups,g{1}); v = R(m,10); v = v(~isnan(v));
    if isempty(v), fprintf('  %-4s: κανένας αντιστοιχίσιμος ισχυρισμός\n', g{1});
    else, fprintf('  %-4s: %d/%d άτομα ίδια κατεύθυνση με τον ισχυρισμό\n', g{1}, sum(v), numel(v)); end
end

T = array2table(R, 'VariableNames', {'subject','mean_dz_wDMN','sd_wDMN','n_gt_thr_wDMN', ...
    'mean_dz_DMNECN','sd_DMNECN','n_gt_thr_DMNECN','mean_dz_unmappable','n_gt_thr_unmappable', ...
    'direction_matches_paper'});
T.group = groups(:);
writetable(T, fullfile(ROOT,'papermap_study2_persubject.csv'));

fprintf('\nΑρχείο: papermap_study2_persubject.csv\n');
fprintf('ΟΡΙΟ 1: αντιστοίχιση ΟΝΟΜΑΣΤΙΚΗ (Table 5), ΟΧΙ χωρικά επικυρωμένη.\n');
fprintf('ΟΡΙΟ 2: ο μέσος 28 ζευγών ΔΕΝ ισούται με το ένα ζεύγος 10-12 του paper.\n');
fprintf('ΟΡΙΟ 3: 14/17 ισχυρισμοί Table 6 είναι ΕΚΤΟΣ των 105 (visual/audial/SMN/LFr/RFr/χωρίς ονομασία).\n');

function out = ternary(c,a,b)
    if c, out=a; else, out=b; end
end
