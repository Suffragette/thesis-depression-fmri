%% describe_tn_study2.m
% Περιγραφική καταγραφή ανά άτομο: μεταβολές triple-network FNC (pre -> post), Study 2.
% ΚΑΘΑΡΑ ΠΕΡΙΓΡΑΦΙΚΟ. Καμία στατιστική δοκιμασία, καμία ερμηνεία.
% Τιμές = Fisher-z (fnc_corrs). Δz = post - pre.

clear; clc;

ROOT   = '.';
FNCDIR = fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
PREFIX = 'nmark_s2_post_process_sub_';
OUT_LONG = fullfile(ROOT,'describe_tn_study2_long.csv');
OUT_SUMM = fullfile(ROOT,'describe_tn_study2_summary.csv');
THRESH = 0.5;
NSUB   = 29;

ECN = 91:93; DMN = 94:101; SAL = 102:105;
TN  = [ECN DMN SAL];                      % 15 ICNs -> 105 ζεύγη

labels = cell(1,105);
for k = 1:105, labels{k} = sprintf('ICN%03d',k); end
for k = ECN,   labels{k} = sprintf('ECN%d',k);   end
for k = DMN,   labels{k} = sprintf('DMN%d',k);   end
for k = SAL,   labels{k} = sprintf('SAL%d',k);   end

groups = repmat({'NT'},1,NSUB);
groups([16 17 18 19 20 23 24 25]) = {'CBT'};
groups([21 22 26 27 28 29])       = {'NFB'};

%% Φόρτωση 58 scans. ΣΕΙΡΑ: index 2i-1 = sub-i ses-pre, 2i = sub-i ses-post
Z = nan(58,105,105);
for f = 1:58
    fn = fullfile(FNCDIR, sprintf('%s%03d.mat', PREFIX, f));
    S = load(fn);
    assert(isfield(S,'fnc_corrs'), 'Λείπει fnc_corrs: %s', fn);
    Z(f,:,:) = squeeze(S.fnc_corrs);
end
fprintf('Φορτώθηκαν 58 scans. Εύρος τιμών: [%.3f, %.3f] (Fisher-z, >1 αναμενόμενο)\n', ...
        min(Z(:)), max(Z(:)));

[ti,tj] = find(triu(true(15),1));
pTN = [TN(ti)' TN(tj)'];                  % 105 x 2
[wi,wj] = find(triu(true(105),1));        % 5460

%% Long table
sub_c={}; grp_c={}; li_c={}; lj_c={}; ci_c=[]; cj_c=[];
zpre_c=[]; zpost_c=[]; dz_c=[]; adz_c=[]; rnk_c=[]; exc_c=[];

summ = zeros(NSUB,8);
fprintf('\n=== ΑΝΑ ΑΤΟΜΟ: triple-network (105 ζεύγη), |Δz| > %.2f ===\n', THRESH);

for s = 1:NSUB
    pre  = squeeze(Z(2*s-1,:,:));
    post = squeeze(Z(2*s,:,:));
    D    = post - pre;

    dTN  = D(sub2ind([105 105], pTN(:,1), pTN(:,2)));
    zpre = pre(sub2ind([105 105], pTN(:,1), pTN(:,2)));
    zpos = post(sub2ind([105 105], pTN(:,1), pTN(:,2)));
    dALL = D(sub2ind([105 105], wi, wj));

    [~,ord] = sort(abs(dTN),'descend');
    rank_of = zeros(105,1); rank_of(ord) = 1:105;

    sdTN  = std(dTN);  sdALL = std(dALL);
    nTN   = sum(abs(dTN)  > THRESH);
    nALL  = sum(abs(dALL) > THRESH);
    % αριθμός αναφοράς: πόσα θα περνούσαν το κατώφλι αν Δz ~ N(0, SD_ατόμου)
    expTN  = 105  * 2 * (1 - normcdf(THRESH/sdTN));
    expALL = 5460 * 2 * (1 - normcdf(THRESH/sdALL));

    summ(s,:) = [s, nTN, expTN, nALL, expALL, sdTN, sdALL, max(abs(dTN))];

    fprintf('\nsub-%02d (%s) | SD(Δz) TN=%.3f όλες=%.3f | >%.1f: TN %d/105 (αναφ. %.1f), όλες %d/5460 (αναφ. %.0f)\n', ...
            s, groups{s}, sdTN, sdALL, THRESH, nTN, expTN, nALL, expALL);
    hit = find(abs(dTN) > THRESH);
    if isempty(hit)
        fprintf('   (καμία triple-network σύνδεση πάνω από το κατώφλι)\n');
        show = ord(1:5);
        fprintf('   5 μεγαλύτερες: ');
        for h = show'
            fprintf('%s-%s %+.3f  ', labels{pTN(h,1)}, labels{pTN(h,2)}, dTN(h));
        end
        fprintf('\n');
    else
        [~,o2] = sort(abs(dTN(hit)),'descend'); hit = hit(o2);
        for h = hit'
            fprintf('   %s-%s : pre %+.3f -> post %+.3f  Δz %+.3f\n', ...
                    labels{pTN(h,1)}, labels{pTN(h,2)}, zpre(h), zpos(h), dTN(h));
        end
    end

    for p = 1:105
        sub_c{end+1,1}  = sprintf('sub-%02d',s);
        grp_c{end+1,1}  = groups{s};
        ci_c(end+1,1)   = pTN(p,1);   cj_c(end+1,1) = pTN(p,2);
        li_c{end+1,1}   = labels{pTN(p,1)};  lj_c{end+1,1} = labels{pTN(p,2)};
        zpre_c(end+1,1) = zpre(p);    zpost_c(end+1,1) = zpos(p);
        dz_c(end+1,1)   = dTN(p);     adz_c(end+1,1)   = abs(dTN(p));
        rnk_c(end+1,1)  = rank_of(p); exc_c(end+1,1)   = abs(dTN(p)) > THRESH;
    end
end

T = table(sub_c, grp_c, ci_c, cj_c, li_c, lj_c, zpre_c, zpost_c, dz_c, adz_c, rnk_c, exc_c, ...
    'VariableNames', {'subject','group','comp_i','comp_j','label_i','label_j', ...
                      'z_pre','z_post','dz','abs_dz','rank_in_subject','exceeds_0p5'});
writetable(T, OUT_LONG);

Ts = array2table(summ, 'VariableNames', {'subject','n_TN_over_thr','ref_TN_chance', ...
     'n_all_over_thr','ref_all_chance','SD_dz_TN','SD_dz_all','max_abs_dz_TN'});
Ts.group = groups(:);
writetable(Ts, OUT_SUMM);

fprintf('\n=== ΣΥΝΟΨΗ ===\n');
fprintf('Άτομα με 0 triple-network συνδέσεις >%.1f: %d/29\n', THRESH, sum(summ(:,2)==0));
fprintf('Διάμεσο SD(Δz) εντός ατόμου: TN %.3f | όλες %.3f\n', median(summ(:,6)), median(summ(:,7)));
obsTN=sum(summ(:,2)); refTN=sum(summ(:,3));
obsALL=sum(summ(:,4)); refALL=sum(summ(:,5));
fprintf('Triple-network : παρατ. %d vs αναφορά %.1f  (λόγος %.2f)\n', obsTN, refTN, obsTN/refTN);
fprintf('Ολος ο connectome: παρατ. %d vs αναφορά %.1f  (λόγος %.2f)\n', obsALL, refALL, obsALL/refALL);
fprintf('Ποσοστό υπερβάσεων που είναι TN: παρατ. %.2f%% vs αναφορά %.2f%%\n', ...
        100*obsTN/obsALL, 100*refTN/refALL);
fprintf('(Το 105/5460=1.92%% ΔΕΝ είναι το σωστό benchmark: αγνοεί τη διαφορά SD.)\n');
fprintf('ΠΡΟΣΟΧΗ: σύγκριση περιγραφική. Οι συνδέσεις είναι συσχετισμένες -> ΟΧΙ p-value.\n');
fprintf('\nΑρχεία:\n  %s\n  %s\n', OUT_LONG, OUT_SUMM);
fprintf('ΣΗΜΕΙΩΣΗ: το κατώφλι 0.5 είναι αυθαίρετο και ΔΕΝ σημαίνει «αλλαγή».\n');
fprintf('Οι στήλες ref_* δείχνουν πόσες υπερβάσεις περιμένεις από θόρυβο και μόνο.\n');
