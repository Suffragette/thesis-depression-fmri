%% tag_paper_map_study2.m
% Αντιστοίχιση ΕΠΙΠΕΔΟΥ ΔΙΚΤΥΟΥ με το Bezmaternykh et al. (2021).
% ΔΕΝ υπάρχει αντιστοίχιση επιπέδου component (χάρτες ICA αδημοσίευτοι).
% LFr (IC9): κανένα αντίστοιχο ICN -> IC9-IC16 και IC1-IC9 ΜΗ ΑΝΤΙΣΤΟΙΧΙΣΙΜΑ.
clear; clc;
ROOT   = '.';
FNCDIR = fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
THRESH = 0.5; NSUB = 29;
ECN=91:93; DMN=94:101; SAL=102:105; TN=[ECN DMN SAL];

groups = repmat({'NT'},1,NSUB);
groups([16 17 18 19 20 23 24 25]) = {'CBT'};
groups([21 22 26 27 28 29])       = {'NFB'};

Z = nan(58,105,105);
for f=1:58
    S = load(fullfile(FNCDIR, sprintf('nmark_s2_post_process_sub_%03d.mat', f)));
    Z(f,:,:) = squeeze(S.fnc_corrs);
end

[ti,tj] = find(triu(true(15),1));
P = [TN(ti)' TN(tj)'];
inE=@(c)c>=91&c<=93; inD=@(c)c>=94&c<=101; inS=@(c)c>=102&c<=105;
cats = {'within-DMN','DMN-ECN','DMN-SAL','ECN-SAL','within-ECN','within-SAL'};
claimed = [true true false false false false];
cid = zeros(105,1);
for p=1:105
    a=P(p,1); b=P(p,2);
    if inD(a)&&inD(b), cid(p)=1;
    elseif (inD(a)&&inE(b))||(inE(a)&&inD(b)), cid(p)=2;
    elseif (inD(a)&&inS(b))||(inS(a)&&inD(b)), cid(p)=3;
    elseif (inE(a)&&inS(b))||(inS(a)&&inE(b)), cid(p)=4;
    elseif inE(a)&&inE(b), cid(p)=5; else, cid(p)=6; end
end

obs = zeros(NSUB,6); ref = zeros(NSUB,6);
for s=1:NSUB
    D = squeeze(Z(2*s,:,:)) - squeeze(Z(2*s-1,:,:));
    d = D(sub2ind([105 105], P(:,1), P(:,2)));
    for c=1:6
        v = d(cid==c);
        obs(s,c) = sum(abs(v)>THRESH);
        ref(s,c) = numel(v)*2*(1-normcdf(THRESH/std(v)));  % SD ανά κατηγορία/άτομο
    end
end

fprintf('\n=== ΑΝΑ ΚΑΤΗΓΟΡΙΑ (29 άτομα αθροιστικά) ===\n');
fprintf('%-12s %5s %6s %8s %6s   %s\n','κατηγορία','ζεύγη','παρατ','αναφορά','λόγος','paper;');
for c=1:6
    fprintf('%-12s %5d %6d %8.1f %6.2f   %s\n', cats{c}, sum(cid==c), ...
        sum(obs(:,c)), sum(ref(:,c)), sum(obs(:,c))/sum(ref(:,c)), ...
        string(claimed(c)));
end
oc=sum(sum(obs(:,claimed))); rc=sum(sum(ref(:,claimed)));
oa=sum(obs(:)); ra=sum(ref(:));
fprintf('\nΣε κατηγορίες του paper: παρατ %d (%.1f%%) vs αναφορά %.1f (%.1f%%)\n', ...
        oc, 100*oc/oa, rc, 100*rc/ra);
for g = {'NT','CBT','NFB'}
    m = strcmp(groups,g{1});
    fprintf('  %-4s: παρατ %d/%d (%.1f%%) vs αναφορά %.1f/%.1f (%.1f%%)\n', g{1}, ...
        sum(sum(obs(m,claimed))), sum(sum(obs(m,:))), ...
        100*sum(sum(obs(m,claimed)))/max(sum(sum(obs(m,:))),1), ...
        sum(sum(ref(m,claimed))), sum(sum(ref(m,:))), ...
        100*sum(sum(ref(m,claimed)))/sum(sum(ref(m,:))));
end

Tc = array2table([ (1:NSUB)' obs ref ], 'VariableNames', ...
     ['subject', strcat('obs_',matlab.lang.makeValidName(cats)), ...
                 strcat('ref_',matlab.lang.makeValidName(cats))]);
Tc.group = groups(:);
writetable(Tc, fullfile(ROOT,'paper_map_study2_bycat.csv'));

T = readtable(fullfile(ROOT,'describe_tn_study2_long.csv'));
key = containers.Map(arrayfun(@(k)sprintf('%d_%d',P(k,1),P(k,2)),1:105,'uni',0), num2cell(cid));
kk = arrayfun(@(k)key(sprintf('%d_%d',T.comp_i(k),T.comp_j(k))), 1:height(T))';
T.paper_category   = cats(kk)';
T.paper_claimed    = claimed(kk)';
writetable(T, fullfile(ROOT,'describe_tn_study2_long_tagged.csv'));

fprintf('\nΑρχεία: paper_map_study2_bycat.csv | describe_tn_study2_long_tagged.csv\n');
fprintf('ΟΡΙΟ: within-ECN (3 ζεύγη) και within-SAL (6) -> SD ασταθής, αναφορά χονδρική.\n');
fprintf('ΟΡΙΟ: αντιστοίχιση ΔΗΛΩΜΕΝΗ σε επίπεδο δικτύου, ΟΧΙ επικυρωμένη χωρικά.\n');
