%% DOMAIN-LEVEL analysis: coarse networks like the paper (DMN, ECN, Salience)
%  Groups 15 NeuroMark sub-networks into 3 domains, tests 6 domain-pairs.
%  This matches the paper's coarse-network granularity (fair comparison).
clear; clc;

OUT  = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output72';
PP   = fullfile(OUT, 'nmark72_postprocess_results');
nSub = 72; nComp = 105;

% Component indices (verified from Neuromark_fMRI_2.2 labels)
ECN = 91:93;      % TN-CE
DMN = 94:101;     % TN-DM
SAL = 102:105;    % TN-SA

% Load full FNC (105x105) per subject
allFNC = zeros(nComp, nComp, nSub);
for i = 1:nSub
    s = load(fullfile(PP, sprintf('nmark72_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs); m(isnan(m))=0;
    allFNC(:,:,i) = m;
end

% Helper: mean connectivity within/between domain sets (off-diagonal for within)
function v = dommean(M, setA, setB, isWithin)
    blk = M(setA, setB);
    if isWithin
        n = numel(setA);
        mask = triu(true(n),1);   % upper triangle only (unique pairs)
        v = mean(blk(mask));
    else
        v = mean(blk(:));
    end
end

% Compute 6 domain-pair scores per subject
scores = zeros(nSub, 6);
names = {'within-DMN','within-ECN','within-SAL','DMN-ECN','DMN-SAL','ECN-SAL'};
for i = 1:nSub
    M = allFNC(:,:,i);
    scores(i,1) = dommean(M, DMN, DMN, true);
    scores(i,2) = dommean(M, ECN, ECN, true);
    scores(i,3) = dommean(M, SAL, SAL, true);
    scores(i,4) = dommean(M, DMN, ECN, false);
    scores(i,5) = dommean(M, DMN, SAL, false);
    scores(i,6) = dommean(M, ECN, SAL, false);
end

grp = [ones(51,1); zeros(21,1)];
dep = grp==1; con = grp==0;

fprintf('=== DOMAIN-LEVEL comparison (coarse networks, like paper) ===\n');
fprintf('=== 6 domain-pairs, N=51 depr vs 21 control ===\n\n');
fprintf('%-14s %10s %10s %8s %8s %9s  %s\n','Domain-pair','depr(M)','ctrl(M)','t','p','Cohen-d','dir');

pvals = zeros(6,1); ts=zeros(6,1); ds=zeros(6,1);
for k = 1:6
    x = scores(dep,k); y = scores(con,k);
    [~,p,~,st] = ttest2(x,y);
    nx=numel(x); ny=numel(y);
    sp = sqrt(((nx-1)*var(x)+(ny-1)*var(y))/(nx+ny-2));
    d = (mean(x)-mean(y))/sp;
    pvals(k)=p; ts(k)=st.tstat; ds(k)=d;
    if mean(x)>mean(y), dir='depr>ctrl'; else, dir='depr<ctrl'; end
    star=''; if p<0.05, star='*'; end
    fprintf('%-14s %10.4f %10.4f %8.3f %8.4f %9.3f  %s %s\n', ...
            names{k}, mean(x), mean(y), st.tstat, p, d, dir, star);
end

% Bonferroni for 6 tests
fprintf('\n=== Multiple-comparison correction (6 tests) ===\n');
bonf = 0.05/6;
fprintf('Bonferroni threshold: p < %.4f\n', bonf);
nsig_unc = sum(pvals<0.05);
nsig_bonf = sum(pvals<bonf);
fprintf('Significant uncorrected (p<0.05): %d/6\n', nsig_unc);
fprintf('Significant Bonferroni-corrected: %d/6\n', nsig_bonf);

% FDR
[ps,ord]=sort(pvals); m=6; fdrthr=(1:m)'/m*0.05; below=ps<=fdrthr;
if any(below), nsig_fdr=sum(pvals<=ps(find(below,1,'last'))); else, nsig_fdr=0; end
fprintf('Significant FDR q<0.05: %d/6\n', nsig_fdr);

fprintf('\n=== COMPARISON TO PAPER ===\n');
fprintf('Paper key findings: decreased within-DMN, altered DMN-ECN (both uncorrected).\n');
fprintf('within-DMN here: p=%.4f, %s\n', pvals(1), ternary(mean(scores(dep,1))>mean(scores(con,1)),'depr>ctrl','depr<ctrl'));
fprintf('DMN-ECN here:    p=%.4f, %s\n', pvals(4), ternary(mean(scores(dep,4))>mean(scores(con,4)),'depr>ctrl','depr<ctrl'));

function s = ternary(cond,a,b)
    if cond, s=a; else, s=b; end
end
