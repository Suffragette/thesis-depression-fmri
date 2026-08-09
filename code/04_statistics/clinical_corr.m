%% clinical_corr.m - Reproduce Tables 7-10: FC <-> clinical change correlations
% Paper claim: baseline FC and DELTA FC predict clinical change (MADRS/BDI/Zung).
% This is the CLINICALLY critical claim (biomarker of treatment response).
% Dual criterion per correlation: (1) sign vs paper, (2) significance.
% Flags: sample size (some n=4-5!), and triple-network mappability.
clear; clc;
ROOT='.';
FD=fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
DMN=94:101; ECN=91:93;
Z=nan(58,105,105);
for f=1:58
    S=load(fullfile(FD,sprintf('nmark_s2_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
T=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
g=string(T.group);
NT=find(g=="depr_no_treatment")'; CBT=find(g=="depr_cbt")'; NFB=find(g=="depr_nfb")';
TR=sort([CBT NFB]);
dMADRS=T.MADRS_ses_post-T.MADRS_ses_pre;
dZung =T.Zung_SDS_ses_post-T.Zung_SDS_ses_pre;
dBDI  =T.BDI_ses_post-T.BDI_ses_pre;
% mappable triple-network pair: 10-12 -> within-DMN proxy (paper post.cing/precuneus)
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
cm=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
baseW=arrayfun(@(s) cm(squeeze(pre(s,:,:)),wP), 1:29)';
dW   =arrayfun(@(s) cm(squeeze(post(s,:,:)),wP)-cm(squeeze(pre(s,:,:)),wP), 1:29)';
baseE=arrayfun(@(s) cm(squeeze(pre(s,:,:)),eP), 1:29)';
dE   =arrayfun(@(s) cm(squeeze(post(s,:,:)),eP)-cm(squeeze(pre(s,:,:)),eP), 1:29)';
fprintf('Loaded. NT=%d CBT=%d NFB=%d TR=%d\n\n', numel(NT),numel(CBT),numel(NFB),numel(TR));
% Paper's significant claims involving MAPPABLE pair 10-12 (within-DMN proxy):
% Table 10 (combined TR): 10-12 baseline<->MADRS r=+0.72; 10-12 dFC<->MADRS r=-0.73
% Table 7 (NT): 10-12 baseline<->Zung r=+0.63 (a); (also many non-mappable pairs)
fprintf('=== MAPPABLE claims (10-12 -> within-DMN); dual criterion ===\n\n');
C={ 'T10 TR base wDMN<->dMADRS', baseW, dMADRS, TR, +0.72; ...
    'T10 TR dwDMN <->dMADRS',    dW,    dMADRS, TR, -0.73; ...
    'T7  NT base wDMN<->dZung',  baseW, dZung,  NT, +0.63; ...
    'T7  NT base wDMN<->dBDI',   baseW, dBDI,   NT, +0.456 };
for i=1:size(C,1)
    x=C{i,2}(C{i,4}); y=C{i,3}(C{i,4}); ok=~isnan(x)&~isnan(y);
    x=x(ok); y=y(ok); n=numel(x);
    [r,p]=corr(x,y); pr=C{i,5};
    fprintf('%-30s n=%2d  r=%+.3f (paper %+.2f) p=%.3f\n', C{i,1}, n, r, pr, p);
    fprintf('%-30s DIR %s | STAT %s\n\n', '', ...
        tern(sign(r)==sign(pr),'agrees','DISAGREES'), tern(p<.05,'sig','ns'));
end

fprintf('=== Power reality check on paper''s own n ===\n');
for n=[4 5 6 10 14]
    rc=tinv(0.975,n-2)/sqrt(n-2+tinv(0.975,n-2)^2);
    fprintf(' n=%2d : |r| needed for p<.05 = %.3f\n', n, rc);
end
fprintf('\n=== How many clinical correlations did the paper run? ===\n');
fprintf('Tables 7-10: ~6 pairs x 3 scales x (base+delta) x 4 groups ~ 100+ tests, 0 correction.\n');
fprintf('Most reported pairs (3-17,5-11,7-11,1-3) are OUTSIDE triple-network.\n');
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
