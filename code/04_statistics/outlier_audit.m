%% outlier_audit.m - Data quality audit, never done before.
% Checks: (a) implausible Fisher-z values, (b) subject-level multivariate
% outliers, (c) whether removing extreme subjects changes conclusions,
% (d) whether any subject's FNC is degenerate (flat / NaN-heavy).
clear; clc;
ROOT='.';
DMN=94:101; ECN=91:93;
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
allP=[wP;eP]; nE=size(allP,1);
gv=@(M,P) arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1));

% ---- load Study 1 (full 105x105 for global checks) ----
S1=nan(72,nE); S1nan=zeros(72,1); S1max=zeros(72,1); S1sd=zeros(72,1);
for i=1:72
    s=load(fullfile(ROOT,'output72','nmark72_postprocess_results', ...
        sprintf('nmark72_post_process_sub_%03d.mat',i)));
    M=squeeze(s.fnc_corrs);
    u=triu(true(105),1);
    S1nan(i)=sum(isnan(M(u))); S1max(i)=max(abs(M(u))); S1sd(i)=std(M(u),'omitnan');
    M(isnan(M))=0; S1(i,:)=gv(M,allP);
end
fprintf('===== A. STUDY 1: raw FNC sanity (all 5460 edges) =====\n');
fprintf('NaN edges  : total=%d  subjects affected=%d\n', sum(S1nan), sum(S1nan>0));
fprintf('max |z|    : range [%.2f, %.2f]  (z>3 implies r>0.995 - suspicious)\n', min(S1max), max(S1max));
fprintf('sub-level SD: range [%.3f, %.3f]\n', min(S1sd), max(S1sd));
bad=find(S1max>3 | S1sd<0.05 | S1sd>0.60);
if isempty(bad), fprintf('>> No implausible scans.\n');
else, fprintf('>> FLAG subjects: %s\n', mat2str(bad')); end
fprintf('\n===== B. Multivariate outliers (52 triple-network edges) =====\n');
mu=mean(S1); C=cov(S1)+eye(nE)*1e-6;
md=sqrt(sum(((S1-mu)/C).*(S1-mu),2));
thr=sqrt(chi2inv(0.999,nE));
fprintf('Mahalanobis: median=%.1f  max=%.1f  threshold(chi2 .999)=%.1f\n', median(md), max(md), thr);
out=find(md>thr);
fprintf('>> outliers: %s\n', tern(isempty(out),'none',mat2str(out')));

fprintf('\n===== C. Leave-one-out on the two primary contrasts =====\n');
w=mean(S1(:,1:size(wP,1)),2); e=mean(S1(:,size(wP,1)+1:end),2);
g=[ones(51,1);zeros(21,1)];
for k=1:2
    y=tern(k==1,w,e); nm=tern(k==1,'within-DMN','DMN-ECN  ');
    [~,p0]=ttest2(y(g==1),y(g==0));
    pj=nan(72,1);
    for i=1:72
        m=true(72,1); m(i)=false;
        [~,pj(i)]=ttest2(y(m&g==1),y(m&g==0));
    end
    fprintf('%s full p=%.3f | LOO range [%.3f, %.3f] | any p<.05? %s\n', ...
        nm, p0, min(pj), max(pj), tern(any(pj<.05),'YES - INFLUENTIAL','no'));
    [~,wi]=min(pj);
    fprintf('%s most influential subject: %d (p drops to %.3f)\n', nm, wi, min(pj));
end

fprintf('\n===== D. STUDY 2: paired deltas =====\n');
D2=nan(29,nE);
for s2=1:29
    a=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results',sprintf('nmark_s2_post_process_sub_%03d.mat',2*s2-1)));
    b=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results',sprintf('nmark_s2_post_process_sub_%03d.mat',2*s2)));
    Ma=squeeze(a.fnc_corrs); Mb=squeeze(b.fnc_corrs); Ma(isnan(Ma))=0; Mb(isnan(Mb))=0;
    D2(s2,:)=gv(Mb,allP)-gv(Ma,allP);
end
sdd=std(D2,0,2);
fprintf('per-subject SD of deltas: median=%.3f range [%.3f, %.3f]\n', median(sdd), min(sdd), max(sdd));
z=(sdd-median(sdd))/(1.4826*mad(sdd,1));
ex=find(abs(z)>3.5);
fprintf('>> robust-z>3.5: %s\n', tern(isempty(ex),'none',mat2str(ex')));
wd=mean(D2(:,1:size(wP,1)),2); NT=1:15;
[~,pNT]=ttest(wd(NT)); pj=nan(15,1);
for i=1:15, m=true(15,1); m(i)=false; [~,pj(i)]=ttest(wd(NT(m))); end
fprintf('NT within-DMN: full p=%.3f | LOO range [%.3f, %.3f]\n', pNT, min(pj), max(pj));
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
