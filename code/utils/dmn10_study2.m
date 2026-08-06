%% dmn10_study2.m - NeuroMark 1.0 posterior/anterior DMN test, Study 2
% PAPER CLAIMS TESTED (Bezmaternykh 2021, Table 6 + Table 11):
%  a1: 10-12 within-DMN, NT n=15, pre .45 -> post .31, t=2.21 p=.044 = DECREASE
%      Table 11/Discussion: 10-12 = POSTERIOR CINGULATE/PRECUNEUS node
%      (IC12 hybrid DMN r=.31 / LFr r=.29 -> imperfect match, declared)
%  a2: 11-16 ECN-DMN, combined TR n=14, pre .14 -> post .37, t=-2.44 p=.030 = INCREASE
%  a3: 11-16 ECN-DMN, NFB n=6,  pre -.10 -> post .28, t=-3.35 p=.020 = INCREASE
% NEUROMARK 1.0: DM = 43-49. Peaks (dmn_peaks_nm10):
%   POSTERIOR 43,44,46,48,49 | ANTERIOR 45(mPFC +35),47(vACC +15)
%   CC (cognitive control, ECN proxy) = 26-42
clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
D=dir(fullfile(ROOT,'output_study2_nm10','*postprocess_results','*post_process_sub_*.mat'));
assert(numel(D)==58, sprintf('Found %d files, expected 58', numel(D)));
[~,ord]=sort({D.name}); D=D(ord);
Z=nan(58,53,53);
for f=1:58
    S=load(fullfile(D(f).folder,D(f).name));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
POST_DMN=[43 44 46 48 49]; ANT_DMN=[45 47]; CC=26:42;
NT=1:15; CBT=[16 17 18 19 20 23 24 25]; NFB=[21 22 26 27 28 29]; TR=sort([CBT NFB]);
wp=@(A) nchoosek(A,2);
cp=@(A,B) [reshape(repmat(A(:),1,numel(B))',[],1) repmat(B(:),numel(A),1)];
cm=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
dv=@(P) arrayfun(@(s) cm(squeeze(post(s,:,:)),P)-cm(squeeze(pre(s,:,:)),P), 1:29)';
dPOST=dv(wp(POST_DMN)); dANT=dv(wp(ANT_DMN)); dALL=dv(wp(43:49));
dPA=dv(cp(ANT_DMN,POST_DMN)); dDCC=dv(cp(43:49,CC)); dPCC=dv(cp(POST_DMN,CC));
fprintf('=== NEUROMARK 1.0 | Study 2 | posterior vs anterior DMN ===\n');
fprintf('pairs: postDMN=%d antDMN=%d allDMN=%d ant-post=%d DMN-CC=%d\n\n',...
  size(wp(POST_DMN),1),size(wp(ANT_DMN),1),size(wp(43:49),1),size(cp(ANT_DMN,POST_DMN),1),size(cp(43:49,CC),1));
T=@(nm,d,g,pdir) run1(nm,d,g,pdir);
fprintf('--- a1 | PAPER: 10-12 within-DMN NT DECREASE (t=2.21 p=.044) ---\n');
T('postDMN  (KEY)',dPOST,NT,-1);
T('allDMN   (cf 2.2)',dALL,NT,-1);
T('antDMN   (control)',dANT,NT,-1);
T('ant-post (control)',dPA,NT,-1);
fprintf('--- a2 | PAPER: 11-16 DMN-ECN combined TR INCREASE (t=-2.44 p=.030) ---\n');
T('DMN-CC',dDCC,TR,+1); T('postDMN-CC',dPCC,TR,+1);
fprintf('--- a3 | PAPER: 11-16 DMN-ECN NFB INCREASE (t=-3.35 p=.020) | n=6 ---\n');
T('DMN-CC',dDCC,NFB,+1); T('postDMN-CC',dPCC,NFB,+1);
fprintf('\nLIMITS: IC12 of paper = hybrid DMN/LFr; mapping nominal (Table 5/11);\n');
fprintf('mean of pair-set ~= single pair of paper; CC(26-42) is ECN proxy in 1.0.\n');
function run1(nm,d,g,pdir)
    x=d(g); [~,p,ci,st]=ttest(x); m=mean(x);
    agree = sign(m)==pdir;
    fprintf('%-20s n=%2d  Dz=%+.4f  t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n',nm,numel(g),m,st.df,st.tstat,p,ci(1),ci(2));
    fprintf('%-20s (1) DIRECTION: %s   (2) STATS: %s\n\n','',...
        ternary(agree,'AGREES with paper','DISAGREES'), ternary(p<.05,'significant','NOT significant'));
end
function o=ternary(c,a,b), if c, o=a; else, o=b; end, end
