%% perm_null.m - Empirical null for the NUMBER of significant edges.
% Fixes the binomial independence assumption in chance_audit.m.
% Method: permutation preserving the real inter-edge dependence
%   Study 1: shuffle group labels (between-subject)
%   Study 2: random sign-flip per subject (paired)
% Output: inflation factor = empirical SD / binomial SD.
clear; clc; rng(42,'twister');
ROOT='.';
DMN=94:101; ECN=91:93; NP=10000; A=0.05;
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
P=[wP;eP]; nE=size(P,1);
fprintf('Edges in triple-network set: %d\n', nE);

% ---- Study 1 ----
F1=nan(72,nE);
for i=1:72
    s=load(fullfile(ROOT,'output72','nmark72_postprocess_results', ...
        sprintf('nmark72_post_process_sub_%03d.mat',i)));
    M=squeeze(s.fnc_corrs); M(isnan(M))=0;
    F1(i,:)=arrayfun(@(k)M(P(k,1),P(k,2)),1:nE);
end
% ---- Study 2 (paired deltas) ----
F2=nan(29,nE);
for s2=1:29
    a=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results', ...
        sprintf('nmark_s2_post_process_sub_%03d.mat',2*s2-1)));
    b=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results', ...
        sprintf('nmark_s2_post_process_sub_%03d.mat',2*s2)));
    Ma=squeeze(a.fnc_corrs); Mb=squeeze(b.fnc_corrs);
    Ma(isnan(Ma))=0; Mb(isnan(Mb))=0;
    F2(s2,:)=arrayfun(@(k)Mb(P(k,1),P(k,2))-Ma(P(k,1),P(k,2)),1:nE);
end
fprintf('Loaded. S1 %dx%d, S2 %dx%d\n\n', size(F1), size(F2));
% ===== Study 1: permute group labels =====
n1=51; n2=21; nu=70; tc=tinv(1-A/2,nu);
cnt1=nan(NP,1);
for p=1:NP
    idx=randperm(72); X=F1(idx(1:n1),:); Y=F1(idx(n1+1:end),:);
    sp=sqrt(((n1-1)*var(X)+(n2-1)*var(Y))/nu);
    t=(mean(X)-mean(Y))./(sp*sqrt(1/n1+1/n2));
    cnt1(p)=sum(abs(t)>tc);
end
% ===== Study 2: sign-flip =====
nu2=28; tc2=tinv(1-A/2,nu2); cnt2=nan(NP,1);
for p=1:NP
    s=sign(randn(29,1)); D=F2.*s;
    t=mean(D)./(std(D)/sqrt(29));
    cnt2(p)=sum(abs(t)>tc2);
end

fprintf('========= EMPIRICAL NULL (%d permutations) =========\n',NP);
fprintf('%-12s %8s %8s %8s %8s %10s\n','study','exp','emp_mean','emp_SD','binom_SD','inflation');
bSD=sqrt(nE*A*(1-A));
for S={{'Study 1',cnt1},{'Study 2',cnt2}}
    nm=S{1}{1}; c=S{1}{2};
    fprintf('%-12s %8.2f %8.2f %8.2f %8.2f %10.2fx\n', nm, nE*A, mean(c), std(c), bSD, std(c)/bSD);
end
fprintf('\n95th percentile of null count: S1=%.0f  S2=%.0f\n', ...
    prctile(cnt1,95), prctile(cnt2,95));

fprintf('\n===== EMPIRICAL p (native %d-edge triple-network set) =====\n', nE);
% Observed significant-edge counts in REAL (unpermuted) data, SAME edges as null
X=F1(1:n1,:); Y=F1(n1+1:end,:);
spO=sqrt(((n1-1)*var(X)+(n2-1)*var(Y))/nu);
tO1=(mean(X)-mean(Y))./(spO*sqrt(1/n1+1/n2));
obs1=sum(abs(tO1)>tc);
tO2=mean(F2)./(std(F2)/sqrt(29));
obs2=sum(abs(tO2)>tc2);
% Empirical one-sided p, +1 correction (Phipson & Smyth 2010)
p1=(1+sum(cnt1>=obs1))/(1+NP);
p2=(1+sum(cnt2>=obs2))/(1+NP);
fprintf('%-10s %6s %6s %10s\n','study','found','exp','p_emp');
fprintf('%-10s %6d %6.2f %10.4f\n','Study 1', obs1, nE*A, p1);
fprintf('%-10s %6d %6.2f %10.4f\n','Study 2', obs2, nE*A, p2);
fprintf('\nNOTE: null AND observed both over the SAME %d triple-network edges.\n',nE);


fprintf('\n===== APPROX p for PAPER counts (normcdf, diff 55/312-edge space; see corr #2) =====\n');
inf1=std(cnt1)/bSD; inf2=std(cnt2)/bSD;
Q={'S1 group comp',55,7,inf1; 'S2 dynamics',312,17,inf2};
fprintf('%-16s %6s %6s %8s %10s %12s\n','analysis','tests','found','exp','p_binom','p_corrected');
for i=1:2
    n=Q{i,2}; f=Q{i,3}; inf=Q{i,4}; e=n*A;
    pb=1-binocdf(f-1,n,A);
    sdc=sqrt(n*A*(1-A))*inf;
    pc=1-normcdf((f-0.5-e)/sdc);
    fprintf('%-16s %6d %6d %8.2f %10.4f %12.4f\n', Q{i,1}, n, f, e, pb, pc);
end
fprintf('\nNOTE: inflation estimated from OUR dependence structure (%d edges),\n',nE);
fprintf('applied to the paper''s counts. Approximate but principled.\n');
