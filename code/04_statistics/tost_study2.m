%% tost_study2.m - Equivalence testing (TOST) for Study 2, NeuroMark 2.2
% Closes the asymmetry: Study 1 had TOST, Study 2 had only "0/24 ns".
% PAIRED design -> dz = mean(d)/sd(d). Bounds in raw units = bound_dz * sd(d).
% SESOI JUSTIFICATION: the paper's own reported effect sizes (Table 6, dz = t/sqrt(n)):
%   10-12 within-DMN NT : t=2.21 n=15 -> dz=0.571
%   11-16 DMN-ECN  TR  : t=2.44 n=14 -> dz=0.652
%   11-16 DMN-ECN  NFB : t=3.35 n=6  -> dz=1.368
clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
FNCDIR=fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
DMN=94:101; ECN=91:93; ALPHA=0.05;
Z=nan(58,105,105);
for f=1:58
    S=load(fullfile(FNCDIR,sprintf('nmark_s2_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
T=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
g=string(T.group);
NT=find(g=="depr_no_treatment")'; CBT=find(g=="depr_cbt")'; NFB=find(g=="depr_nfb")';
TR=sort([CBT NFB]);
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
cm=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
dv=@(P) arrayfun(@(s) cm(squeeze(post(s,:,:)),P)-cm(squeeze(pre(s,:,:)),P), 1:29)';
wD=dv(wP); eD=dv(eP);
fprintf('======== TOST EQUIVALENCE, STUDY 2 (NeuroMark 2.2) ========\n');
fprintf('Paired design. SESOI = effect size reported by the paper.\n\n');
C={ 'within-DMN | NT  (paper dz=0.571)', wD, NT, 0.571; ...
    'DMN-ECN    | TR  (paper dz=0.652)', eD, TR, 0.652; ...
    'DMN-ECN    | NFB (paper dz=1.368)', eD, NFB, 1.368; ...
    'within-DMN | all29 (descriptive)',  wD, 1:29, 0.571 };
for k=1:size(C,1)
    x=C{k,2}(C{k,3}); n=numel(x); nu=n-1; pdz=C{k,4};
    m=mean(x); s=std(x); se=s/sqrt(n); dz=m/s;
    [~,p,ci]=ttest(x); t=m/se;
    fprintf('--- %s ---\n', C{k,1});
    fprintf(' n=%2d  mean Dz=%+.4f  dz=%+.3f  t(%d)=%+.2f  p=%.3f  95%%CI[%+.4f,%+.4f]\n', ...
        n, m, dz, nu, t, p, ci(1), ci(2));
    b=0.20:0.05:1.40; pT=nan(size(b));
    for i=1:numel(b)
        raw=b(i)*s;
        pT(i)=max(1-tcdf((m+raw)/se,nu), tcdf((m-raw)/se,nu));
    end
    idx=find(pT<ALPHA,1);
    if isempty(idx)
        fprintf(' >> TOST: cannot reject even |dz|=%.2f. UNINFORMATIVE.\n', b(end));
    else
        fprintf(' >> TOST: smallest rejectable |dz| = %.2f\n', b(idx));
    end
    j=find(abs(b-round(pdz*20)/20)<1e-9,1);
    if ~isempty(j)
        fprintf(' >> at paper dz=%.3f (grid %.2f): p_TOST=%.4f -> %s\n', ...
            pdz, b(j), pT(j), tern(pT(j)<ALPHA,'PAPER EFFECT EXCLUDED','not excluded'));
    end
    fprintf(' >> power note: n=%d can only exclude large effects.\n\n', n);
end
fprintf('INTERPRETATION LIMITS:\n');
fprintf(' - Equivalence bounds are LARGE. Small/moderate effects remain compatible.\n');
fprintf(' - Claim is: effects of the magnitude reported by the paper are excluded.\n');
fprintf(' - NOT a claim that no difference exists.\n');
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
