%% LAG-SHIFT SENSITIVITY ANALYSIS (Study 1, ds002748)
%
%  WHY: Bezmaternykh et al. (2021, p.4) computed FNC with the FNC toolbox's
%  Lag-Shift algorithm: "the coefficients and the lag times for each pair of
%  networks were computed. The time shift was selected to maximize an absolute
%  value of correlation coefficient."
%  Our main analysis used zero-lag Pearson (GIFT fnc_corrs). That is a
%  DIFFERENT ESTIMAND: max-over-lags is positively biased in magnitude.
%  This script computes BOTH from the SAME timecourses and asks whether the
%  group-level conclusions depend on the choice.
%
%  Input : output72/nmark72_ica_br{k}.mat -> compSet.tc  [100 x 105]
%  Output: side-by-side zero-lag vs lag-shift for the two prespecified
%          contrasts and for all 105 triple-network connections.
clear; clc;

DIR   = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output72';
nSub  = 72; nDep = 51;
ECN   = 91:93; DMN = 94:101; SAL = 102:105;
NOI   = [ECN DMN SAL];          % 15 components
MAXLAG = 4;                     % +/- 4 TRs = +/- 10 s (TR = 2.5)
ALPHA = 0.05;

dom = strings(105,1); dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";

%% ---- compute both FNC estimators from the same timecourses ----
nN = numel(NOI);
FZ = nan(nN,nN,nSub);   % zero-lag
FL = nan(nN,nN,nSub);   % lag-shift max-|r|
LAGS = nan(nN,nN,nSub); % chosen lag

fprintf('Computing zero-lag and lag-shift FNC for %d subjects...\n', nSub);
for k = 1:nSub
    f = fullfile(DIR, sprintf('nmark72_ica_br%d.mat', k));
    if ~exist(f,'file'), error('Missing %s', f); end
    s  = load(f);
    tc = s.compSet.tc(:, NOI);            % 100 x 15
    tc = detrend(tc);                     % same for both estimators
    T  = size(tc,1);
    for a = 1:nN
        for b = a+1:nN
            x = tc(:,a); y = tc(:,b);
            r0 = corr(x,y);
            FZ(a,b,k) = r0; FZ(b,a,k) = r0;
            % scan lags
            best = r0; bestL = 0;
            for L = 1:MAXLAG
                r1 = corr(x(1:T-L),   y(1+L:T));    % y lags x
                r2 = corr(x(1+L:T),   y(1:T-L));    % x lags y
                if abs(r1) > abs(best), best = r1; bestL = +L; end
                if abs(r2) > abs(best), best = r2; bestL = -L; end
            end
            FL(a,b,k) = best;  FL(b,a,k) = best;
            LAGS(a,b,k) = bestL; LAGS(b,a,k) = -bestL;
        end
    end
    if mod(k,20)==0, fprintf('  %d/%d\n', k, nSub); end
end
fprintf('done.\n\n');

%% ---- how different are the two estimators? ----
msk = triu(true(nN),1);
z = []; l = [];
for k = 1:nSub
    a = FZ(:,:,k); b = FL(:,:,k);
    z = [z; a(msk)]; l = [l; b(msk)];
end
fprintf('======== ESTIMATOR COMPARISON ========\n');
fprintf('correlation between the two FNC estimates : r = %.3f\n', corr(z,l));
fprintf('mean |r| zero-lag  : %.3f\n', mean(abs(z)));
fprintf('mean |r| lag-shift : %.3f   (inflation: +%.1f%%)\n', mean(abs(l)), 100*(mean(abs(l))/mean(abs(z))-1));
allL = LAGS(repmat(msk,1,1,nSub));
fprintf('chosen lag = 0 in %.1f%% of pairs; |lag|>=2 in %.1f%%\n', ...
        100*mean(allL==0), 100*mean(abs(allL)>=2));
fprintf('(max-over-lags is positively biased by construction)\n\n');

%% ---- prespecified contrasts, both estimators ----
grp = [ones(nDep,1); zeros(nSub-nDep,1)]; dep = grp==1; con = grp==0;
n1 = sum(dep); n2 = sum(con); nu = n1+n2-2; tcrit = tinv(1-ALPHA/2,nu);
iECN = 1:3; iDMN = 4:11; iSAL = 12:15;      % indices within NOI

labels = {'within-DMN','DMN-ECN'};
defs   = {{iDMN,iDMN,1},{iDMN,iECN,0}};

fprintf('======== PRESPECIFIED CONTRASTS ========\n');
for e = 1:2
    if e==1, F = FZ; ename = 'ZERO-LAG (main)'; else, F = FL; ename = 'LAG-SHIFT (paper estimator)'; end
    fprintf('--- %s ---\n', ename);
    fprintf('%-12s %8s %8s %8s %20s\n','contrast','t','p','d','95%% CI on d');
    for c = 1:2
        A = defs{c}{1}; B = defs{c}{2}; within = defs{c}{3};
        sc = nan(nSub,1);
        for k = 1:nSub
            blk = F(A,B,k);
            if within, m2 = triu(true(numel(A)),1); sc(k) = mean(blk(m2));
            else, sc(k) = mean(blk(:)); end
        end
        x = sc(dep); y = sc(con);
        md = mean(x)-mean(y);
        sp = sqrt(((n1-1)*var(x)+(n2-1)*var(y))/nu);
        se = sp*sqrt(1/n1+1/n2);
        d = md/sp; t = md/se; p = 2*(1-tcdf(abs(t),nu));
        fprintf('%-12s %8.3f %8.4f %8.3f  [%+.3f, %+.3f]\n', labels{c}, t, p, d, ...
                (md-tcrit*se)/sp, (md+tcrit*se)/sp);
    end
    fprintf('\n');
end

%% ---- per-connection, both estimators ----
fprintf('======== ALL %d CONNECTIONS ========\n', nN*(nN-1)/2);
for e = 1:2
    if e==1, F = FZ; ename = 'zero-lag'; else, F = FL; ename = 'lag-shift'; end
    ps = []; ds = [];
    for a = 1:nN
      for b = a+1:nN
        x = squeeze(F(a,b,dep)); y = squeeze(F(a,b,con));
        md = mean(x)-mean(y);
        sp = sqrt(((n1-1)*var(x)+(n2-1)*var(y))/nu);
        t = md/(sp*sqrt(1/n1+1/n2));
        ps = [ps; 2*(1-tcdf(abs(t),nu))]; ds = [ds; md/sp];
      end
    end
    [~,~,~,fdr] = fdr_bh_local(ps);
    fprintf('%-10s : p<0.05 uncorrected %2d/%d | survive FDR %d | max|d| %.3f | mean|d| %.3f\n', ...
            ename, sum(ps<0.05), numel(ps), sum(fdr<0.05), max(abs(ds)), mean(abs(ds)));
end

fprintf(['\nCONCLUSION TEMPLATE:\n' ...
         'If both estimators give the same qualitative answer, state:\n' ...
         '  "Results were unchanged when FNC was estimated with the lag-shift\n' ...
         '   max-|r| algorithm used by the original study (+/-%d TRs); see Table Sx."\n' ...
         'If they differ, that difference IS a finding and must be reported.\n'], MAXLAG);

%% simple BH-FDR
function [h, crit, adj, q] = fdr_bh_local(p)
    p = p(:); m = numel(p);
    [ps, idx] = sort(p);
    q = zeros(m,1);
    qs = min(1, ps .* m ./ (1:m)');
    for i = m-1:-1:1, qs(i) = min(qs(i), qs(i+1)); end
    q(idx) = qs;
    h = q < 0.05; crit = NaN; adj = q;
end
