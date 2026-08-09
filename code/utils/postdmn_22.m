%% postdmn_22.m - Posterior-DMN test in the PRIMARY parcellation (NeuroMark 2.2)
% Division is EXTERNALLY derived: each DMN ICN assigned to the Smith-2009 RSN
% it correlates most with; RSN7/RSN15 are posterior (Y=-36.5,-33.1),
% RSN11 is anterior (Y=+6.6). Converges with our |z|-weighted centroids.
%   POSTERIOR : 96,97,98,99   (attach to RSN7/15)
%   ANTERIOR  : 95,100,101    (attach to RSN11)
%   EXCLUDED  : 94            (attaches to frontoparietal RSN13, r=.38)
% PAPER CLAIM (Table 6): 10-12 = posterior cingulate/precuneus <-> hybrid DMN/LFr,
%   NT n=15, pre .45 -> post .31, t=2.21 p=.044  => DECREASE
clear; clc;
ROOT='.';
FD=fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
POST=[96 97 98 99]; ANT=[95 100 101]; ALLD=94:101; ECN=91:93;
Z=nan(58,105,105);
for f=1:58
    S=load(fullfile(FD,sprintf('nmark_s2_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
T=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
g=string(T.group); NT=find(g=="depr_no_treatment")';
TR=sort([find(g=="depr_cbt")' find(g=="depr_nfb")']);
cm=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
dv=@(P) arrayfun(@(s) cm(squeeze(post(s,:,:)),P)-cm(squeeze(pre(s,:,:)),P), 1:29)';
cp=@(A,B) [reshape(repmat(A(:),1,numel(B))',[],1) repmat(B(:),numel(A),1)];
S={ 'posterior-DMN within (KEY)', nchoosek(POST,2); ...
    'posterior-DMN <-> ECN',      cp(POST,ECN); ...
    'anterior-DMN within (ctrl)', nchoosek(ANT,2); ...
    'post <-> ant (ctrl)',        cp(POST,ANT); ...
    'ALL DMN within (cf. old)',   nchoosek(ALLD,2); ...
    'posterior +94 (sens.)',      nchoosek([POST 94],2) };
fprintf('===== NT group (n=15) | paper says DECREASE =====\n\n');
for i=1:size(S,1)
    d=dv(S{i,2}); x=d(NT); [~,p,ci,st]=ttest(x);
    dz=mean(x)/std(x);
    pj=nan(15,1);
    for k=1:15, m=true(15,1); m(k)=false; [~,pj(k)]=ttest(x(m)); end
    fprintf('%-28s pairs=%2d  Dz=%+.4f dz=%+.2f t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n', ...
        S{i,1}, size(S{i,2},1), mean(x), dz, st.df, st.tstat, p, ci(1), ci(2));
    fprintf('%-28s (1)DIR %s  (2)STAT %s  LOO p[%.3f,%.3f]\n\n', '', ...
        tern(mean(x)<0,'agrees','DISAGREES'), tern(p<.05,'sig','ns'), min(pj), max(pj));
end
fprintf('===== TR group (n=14), same measures =====\n');
for i=[1 2]
    d=dv(S{i,2}); x=d(TR); [~,p]=ttest(x);
    fprintf('%-28s Dz=%+.4f p=%.3f\n', S{i,1}, mean(x), p);
end
fprintf('\nLIMITS: IC12 of paper is hybrid DMN/LFr -> two partial analogues tested.\n');
fprintf('Mean of a pair-set is not the paper single pair. Mapping remains nominal.\n');
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
