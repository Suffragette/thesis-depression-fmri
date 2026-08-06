clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
D=dir(fullfile(ROOT,'output_study2_nm10','*postprocess_results','*post_process_sub_*.mat'));
[~,ord]=sort({D.name}); D=D(ord);
Z=nan(58,53,53);
for f=1:58, S=load(fullfile(D(f).folder,D(f).name)); Z(f,:,:)=squeeze(S.fnc_corrs); end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
T=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
g=string(T.group); NT=find(g=="depr_no_treatment")';
PW=[43 44 46 48 49]; PS=[43 44 48 49]; CC=26:42;
cm=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
dv=@(P) arrayfun(@(s) cm(squeeze(post(s,:,:)),P)-cm(squeeze(pre(s,:,:)),P), 1:29)';
cp=@(A,B) [reshape(repmat(A(:),1,numel(B))',[],1) repmat(B(:),numel(A),1)];
fprintf('PAPER a1: 10-12 = posteriorDMN <-> HYBRID(DMN+LFr), NT n=15, DECREASE\n');
fprintf('Two partial analogues (IC12 is hybrid):\n\n');
sets={ 'postDMN-within (DMN part)', nchoosek(PW,2); ...
       'postDMN-CC (LFr part)', cp(PW,CC); ...
       'postDMN-within STRICT (no DM46)', nchoosek(PS,2); ...
       'postDMN-CC STRICT (no DM46)', cp(PS,CC) };
for i=1:size(sets,1)
    d=dv(sets{i,2}); x=d(NT);
    [~,p,ci,st]=ttest(x);
    fprintf('%-32s pairs=%3d  Dz=%+.4f  t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n', ...
        sets{i,1}, size(sets{i,2},1), mean(x), st.df, st.tstat, p, ci(1), ci(2));
    fprintf('%-32s DIRECTION %s | STATS %s\n', '', ...
        tern(mean(x)<0,'agrees','DISAGREES'), tern(p<.05,'sig','ns'));
    if i==1
        fprintf('   per-subject: %s\n', num2str(round(x',3)));
        fprintf('   median=%+.4f  negatives=%d/15  |max|=%.3f\n', median(x), sum(x<0), max(abs(x)));
        [~,pw]=ttest(x(abs(x)<max(abs(x))));
        fprintf('   drop largest |Dz| -> p=%.3f\n', pw);
    end
    fprintf('\n');
end
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
