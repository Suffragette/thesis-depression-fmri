%% chance_audit.m
% Are the paper's reported findings distinguishable from chance?
% Pure arithmetic on the paper's own reported numbers. No data required.
% Sources: Results text + Tables 3,6,7-10 of Bezmaternykh et al. 2021.
clear; clc; a=0.05;
fprintf('=========== CHANCE AUDIT: Bezmaternykh et al. 2021 ===========\n');
fprintf('Question: do reported findings exceed the false-positive rate\n');
fprintf('expected under the null, given NO correction (paper admits none)?\n\n');

B={};
% --- STUDY 1 ---
% "11 of 20 components suited criterion of grey matter prevalence, which led to 55 pairs"
% "Seven pairs demonstrated intergroup differences significant at p<0.05"
B(end+1,:)={'Study 1: group comparison', 55, 7};
% Table 4: correlations with ZSRDS on 5 pairs, 2 significant
B(end+1,:)={'Study 1: FC-ZSRDS corr (Table 4)', 5, 2};

% --- STUDY 2 ---
% "13 of 17 components were considered as grey matter ones, so 78 pairs were tested"
% Tested in FOUR groups: NT(15), combined TR(14), CBT(8), NFB(6)
% Table 6 significant rows: NT 5, TR 5, CBT 4 (1-3 is n/s at .051), NFB 3 = 17
B(end+1,:)={'Study 2: dynamics, 4 groups', 78*4, 17};

fprintf('%-36s %7s %7s %7s %8s\n','Analysis','tests','exp_FP','found','ratio');
tot_t=0; tot_e=0; tot_f=0;
for i=1:size(B,1)
    n=B{i,2}; f=B{i,3}; e=n*a;
    fprintf('%-36s %7d %7.1f %7d %8.2f\n', B{i,1}, n, e, f, f/e);
    tot_t=tot_t+n; tot_e=tot_e+e; tot_f=tot_f+f;
end
fprintf('%-36s %7d %7.1f %7d %8.2f\n','TOTAL',tot_t,tot_e,tot_f,tot_f/tot_e);

fprintf('\n--- Binomial test: is the count above chance? ---\n');
for i=1:size(B,1)
    n=B{i,2}; f=B{i,3};
    p=1-binocdf(f-1,n,a);
    fprintf('%-36s P(>=%d of %d | H0) = %.4f  %s\n', B{i,1}, f, n, p, ...
        tern(p<.05,'above chance','INDISTINGUISHABLE from chance'));
end
p=1-binocdf(tot_f-1,tot_t,a);
fprintf('%-36s P(>=%d of %d | H0) = %.4f\n','TOTAL',tot_f,tot_t,p);

fprintf('\n--- Bonferroni threshold the paper would have needed ---\n');
fprintf('Study 2: a/312 = %.5f. Paper''s smallest dynamic p = 0.002 (7-11). Survives? %s\n', ...
    a/312, tern(0.002 < a/312,'yes','NO'));
fprintf('Study 1: a/55  = %.5f. Paper''s smallest p = 0.004 (9-16).       Survives? %s\n', ...
    a/55, tern(0.004 < a/55,'yes','NO'));
fprintf('\nThe key pair 10-12 (p=0.044) is one of 312 tests.\n');
fprintf('Expected number of tests with p<=0.044 under H0: %.1f\n', 312*0.044);

fprintf('\n--- Study 2: consistency of numerator vs denominator ---\n');
fprintf('CBT,NFB are SUBSETS of TR (overlapping subjects).\n');
schemes={'(i) all 4 groups', 78*4, 17; ...
         '(ii) disjoint NT+TR', 78*2, 10; ...
         '(iii) INCONSISTENT: 17 over 156', 78*2, 17};
fprintf('%-34s %5s %5s %8s\n','scheme','num','den','P(>=num)');
for k=1:size(schemes,1)
    nn=schemes{k,2}; ff=schemes{k,3};
    fprintf('%-34s %5d %5d %8.4f\n', schemes{k,1}, ff, nn, 1-binocdf(ff-1,nn,a));
end
fprintf('Only the INCONSISTENT scheme (double-counts overlap) reaches p<.05.\n');
fprintf('Every consistent count -> chance. binomial assumes independence,\n');
fprintf('so ~1.3x dependence inflation (see perm_null.m) makes p even LARGER.\n');

function o=tern(c,x,y), if c, o=x; else, o=y; end, end
