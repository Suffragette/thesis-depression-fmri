%% TOST equivalence testing + Bayes factors on the two PRESPECIFIED contrasts
%  Study 1 (ds002748, n=72: 51 depressed vs 21 controls), NeuroMark 2.2 FNC.
%  Purpose: turn "0 significant" (a description) into "effects larger than
%  d = X are rejected" (a measurement).
%
%  Contrasts (prespecified):
%    C1: within-DMN      = mean of upper triangle of FNC(94:101, 94:101)
%    C2: DMN-ECN         = mean of FNC(94:101, 91:93)
%
%  Outputs per contrast: mean diff, Cohen's d + 95% CI, classic t-test,
%  TOST at a range of bounds, smallest rejectable |d|, JZS Bayes factor.
clear; clc;

PP    = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output72/nmark72_postprocess_results';
nSub  = 72;
nDep  = 51;                    % sub-001..051 depressed, sub-052..072 control
ECN   = 91:93;
DMN   = 94:101;
ALPHA = 0.05;

%% ---- load FNC ----
FNC = nan(105,105,nSub);
for i = 1:nSub
    f = fullfile(PP, sprintf('nmark72_post_process_sub_%03d.mat', i));
    if ~exist(f,'file'), error('Missing: %s', f); end
    s = load(f);
    m = squeeze(s.fnc_corrs);
    m(isnan(m)) = 0;
    FNC(:,:,i) = m;
end
fprintf('Loaded FNC: %dx%dx%d\n\n', size(FNC));

grp = [ones(nDep,1); zeros(nSub-nDep,1)];
dep = grp==1; con = grp==0;

%% ---- contrast scores per subject ----
scores = nan(nSub,2);
maskW  = triu(true(numel(DMN)),1);
for i = 1:nSub
    M = FNC(:,:,i);
    b1 = M(DMN,DMN);   scores(i,1) = mean(b1(maskW));   % within-DMN
    b2 = M(DMN,ECN);   scores(i,2) = mean(b2(:));       % DMN-ECN
end
labels = {'within-DMN','DMN-ECN'};

%% ---- analysis per contrast ----
for k = 1:2
    x = scores(dep,k);  y = scores(con,k);
    n1 = numel(x); n2 = numel(y); nu = n1+n2-2;
    m1 = mean(x); m2 = mean(y); md = m1-m2;
    sp = sqrt(((n1-1)*var(x) + (n2-1)*var(y)) / nu);
    se = sp*sqrt(1/n1 + 1/n2);
    d  = md/sp;
    t  = md/se;
    p  = 2*(1 - tcdf(abs(t), nu));

    % 95% CI on d (via CI on mean diff / sp)
    tcrit = tinv(1-ALPHA/2, nu);
    dLo = (md - tcrit*se)/sp;  dHi = (md + tcrit*se)/sp;

    fprintf('==================== %s ====================\n', labels{k});
    fprintf('depressed  n=%2d  mean=%+.4f (sd %.4f)\n', n1, m1, std(x));
    fprintf('controls   n=%2d  mean=%+.4f (sd %.4f)\n', n2, m2, std(y));
    fprintf('mean diff  %+.4f | t(%d)=%+.3f | p=%.4f\n', md, nu, t, p);
    fprintf('Cohen''s d  %+.3f  95%% CI [%+.3f, %+.3f]\n\n', d, dLo, dHi);

    % ---- TOST across a grid of equivalence bounds ----
    fprintf('TOST (two one-sided tests), alpha=%.2f\n', ALPHA);
    fprintf('%8s %10s %10s %10s   %s\n','bound d','p_lower','p_upper','p_TOST','equivalent?');
    bounds = 0.30:0.05:1.00;
    pT = nan(size(bounds));
    for b = 1:numel(bounds)
        raw = bounds(b)*sp;                       % bound in raw units
        t1  = (md + raw)/se;  p1 = 1 - tcdf(t1, nu);   % H0: diff <= -raw
        t2  = (md - raw)/se;  p2 = tcdf(t2, nu);       % H0: diff >= +raw
        pT(b) = max(p1,p2);
        fprintf('%8.2f %10.4f %10.4f %10.4f   %s\n', bounds(b), p1, p2, pT(b), ...
                char("no " + (pT(b)<ALPHA)*"YES"));
    end
    idx = find(pT < ALPHA, 1, 'first');
    if isempty(idx)
        fprintf('\n>> Cannot reject even d=%.2f. Data uninformative at these bounds.\n\n', bounds(end));
    else
        fprintf('\n>> Smallest rejectable bound: |d| >= %.2f  (effects this large or larger are excluded)\n', bounds(idx));
        fprintf('>> Effects smaller than d=%.2f remain compatible with the data.\n\n', bounds(idx));
    end

    % ---- JZS Bayes factor (Rouder et al. 2009), r = 0.707 ----
    bf10 = jzs_bf(t, n1, n2, 0.707);
    fprintf('Bayes factor BF10 = %.3f   ->  BF01 = %.2f\n', bf10, 1/bf10);
    if 1/bf10 > 3
        fprintf('   (BF01>3: moderate evidence FOR the null)\n');
    elseif 1/bf10 > 1
        fprintf('   (BF01>1: weak/anecdotal evidence for the null)\n');
    else
        fprintf('   (BF01<1: data do not favour the null)\n');
    end
    fprintf('\n');
end

fprintf(['NOTE: this is the unadjusted group contrast. The prespecified models\n' ...
         'included age, sex and mean FD as covariates; report both, or rerun\n' ...
         'TOST on covariate-residualised scores for full consistency.\n']);

%% ---- helper: JZS Bayes factor for two-sample t ----
function bf10 = jzs_bf(t, n1, n2, r)
    N  = n1*n2/(n1+n2);
    nu = n1+n2-2;
    % prior on g: inverse-gamma(1/2, r^2/2)
    prior = @(g) (r./sqrt(2*pi)) .* g.^(-1.5) .* exp(-(r^2)./(2*g));
    like  = @(g) (1+N.*g).^(-0.5) .* (1 + t.^2./((1+N.*g).*nu)).^(-(nu+1)/2);
    num   = integral(@(g) like(g).*prior(g), 0, Inf, 'AbsTol',1e-10, 'RelTol',1e-8);
    den   = (1 + t.^2./nu).^(-(nu+1)/2);
    bf10  = num/den;
end
