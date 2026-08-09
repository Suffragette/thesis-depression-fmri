%% repro1012_full.m
% ΠΛΗΡΗΣ αναπαραγωγή του ισχυρισμού 10-12 (& συγγενικού 11-16) του paper, Study 2.
% Πέντε σκέλη, σωστή ομάδα το καθένα. ΚΑΤΑΓΡΑΦΗ όλων + επιφυλάξεων.
% ΒΑΣΗ: NeuroMark 2.2. DMN=ICN94-101, ECN=91-93.
%
% ΕΠΙΦΥΛΑΞΗ Α (μπαίνει σε κάθε σκέλος): το IC12 του paper είναι ΥΒΡΙΔΙΚΟ
%   DMN(r=.31)/LFr(r=.29) [Table 11]. Το "within-DMN" του paper ΔΕΝ είναι καθαρό DMN.
%   Η αντιστοίχιση με το καθαρό TN-DM του NeuroMark είναι ατελής by design.
% ΕΠΙΦΥΛΑΞΗ Β: το paper παραδέχεται (σελ.10) ότι το 10-12 "if not treated as a false positive".
% ΕΠΙΦΥΛΑΞΗ Γ: σκέλη β/γ σε n=10-14 (MADRS: ~4-5). Το paper βρίσκει εκεί r=±1.00 (Table 9)=θόρυβος.

clear; clc;
ROOT   = '.';
FNCDIR = fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
CLIN   = fullfile(ROOT,'clinical_study2.tsv');
NSUB=29; DMN=94:101; ECN=91:93;

% ---- FNC ----
Z = nan(58,105,105);
for f=1:58
    S=load(fullfile(FNCDIR,sprintf('nmark_s2_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
avg=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
wpre=zeros(NSUB,1);wpost=wpre;epre=wpre;epost=wpre;
for s=1:NSUB
    A=squeeze(pre(s,:,:));B=squeeze(post(s,:,:));
    wpre(s)=avg(A,wP);wpost(s)=avg(B,wP);epre(s)=avg(A,eP);epost(s)=avg(B,eP);
end
wD=wpost-wpre; eD=epost-epre;

% ---- clinical ----
T=readtable(CLIN,'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a','NA'});
getnum=@(col) str2double(string(T.(col)));
bdi_pre=getnum('BDI_ses_pre'); bdi_post=getnum('BDI_ses_post');
zung_pre=getnum('Zung_SDS_ses_pre'); zung_post=getnum('Zung_SDS_ses_post');
mad_pre=getnum('MADRS_ses_pre'); mad_post=getnum('MADRS_ses_post');
dBDI=bdi_post-bdi_pre; dZung=zung_post-zung_pre; dMAD=mad_post-mad_pre;

grp=string(T.group);
NT  = find(grp=="depr_no_treatment");
CBT = find(grp=="depr_cbt");
NFB = find(grp=="depr_nfb");
TR  = [CBT;NFB];
fprintf('Ομάδες: NT=%d, CBT=%d, NFB=%d, TR(combined)=%d\n',numel(NT),numel(CBT),numel(NFB),numel(TR));
fprintf('(αν CBT/NFB=0, το group column έχει άλλες ετικέτες — δες grp μοναδικές:)\n');
disp(unique(grp));

pr=@(v) fprintf('%+.4f',v);
line=@() fprintf([repmat('-',1,70) '\n']);

fprintf('\n================ ΠΛΗΡΗΣ ΑΝΑΠΑΡΑΓΩΓΗ 10-12 ================\n');

%% α1: within-DMN μείωση, NT (Table 6: t=2.21 p=.044)
line(); fprintf('α1 | within-DMN Δz, NT (n=%d) | paper: ΜΕΙΩΣΗ t=2.21 p=.044\n',numel(NT));
[~,p,ci,st]=ttest(wD(NT));
fprintf('   mean Δz='); pr(mean(wD(NT)));
fprintf('  t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n',st.df,st.tstat,p,ci(1),ci(2));
fprintf('   -> %s\n', ternary(p<.05 && mean(wD(NT))<0,'ΑΝΑΠΑΡΑΓΕΤΑΙ','ΔΕΝ αναπαράγεται'));

%% α2: DMN-ECN αύξηση, combined TR (Table 6: 11-16 t=-2.44 p=.030)
line(); fprintf('α2 | DMN-ECN Δz, combined TR (n=%d) | paper: ΑΥΞΗΣΗ t=-2.44 p=.030\n',numel(TR));
[~,p,ci,st]=ttest(eD(TR));
fprintf('   mean Δz='); pr(mean(eD(TR)));
fprintf('  t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n',st.df,st.tstat,p,ci(1),ci(2));
fprintf('   -> %s\n', ternary(p<.05 && mean(eD(TR))>0,'ΑΝΑΠΑΡΑΓΕΤΑΙ','ΔΕΝ αναπαράγεται'));

%% α3: DMN-ECN αύξηση, NFB (Table 6: 11-16 t=-3.35 p=.020, n=6)
line(); fprintf('α3 | DMN-ECN Δz, NFB (n=%d) | paper: ΑΥΞΗΣΗ t=-3.35 p=.020 | n=6 ΜΗΝ ΕΡΜΗΝΕΥΤΕΙ\n',numel(NFB));
[~,p,ci,st]=ttest(eD(NFB));
fprintf('   mean Δz='); pr(mean(eD(NFB)));
fprintf('  t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f]\n',st.df,st.tstat,p,ci(1),ci(2));

%% β: baseline within-DMN προβλέπει βελτίωση, NT (Table 7: 10-12 vs Zung r=.63)
line(); fprintf('β  | baseline wDMN vs ΔZung, NT | paper: r=.63 p<.05\n');
m=NT; ok=~isnan(wpre(m))&~isnan(dZung(m)); n=sum(ok);
[r,pp]=corr(wpre(m(ok)),dZung(m(ok)),'type','Spearman');
fprintf('   n=%d  r=%+.3f p=%.3f  %s\n',n,r,pp,ternary(n<10,'*** n<10: ΜΗ ΣΥΜΠΕΡΑΣΜΑΤΙΚΟ ***',''));

%% γ: Δwithin-DMN vs ΔMADRS, combined TR (Table 10: 10-12 vs MADRS change r=-.734)
line(); fprintf('γ  | ΔwDMN vs ΔMADRS, combined TR | paper: r=-.734 p<.05\n');
m=TR; ok=~isnan(wD(m))&~isnan(dMAD(m)); n=sum(ok);
if n>=3
    [r,pp]=corr(wD(m(ok)),dMAD(m(ok)),'type','Spearman');
    fprintf('   n=%d  r=%+.3f p=%.3f  %s\n',n,r,pp,ternary(n<10,'*** n<10: ΜΗ ΣΥΜΠΕΡΑΣΜΑΤΙΚΟ (paper: r=±1.00 σε n=3-4) ***',''));
else
    fprintf('   n=%d  ΑΔΥΝΑΤΟ (πολύ λίγα MADRS)\n',n);
end

line();
fprintf('\nΕΠΙΦΥΛΑΞΕΙΣ (σε ΟΛΑ τα σκέλη):\n');
fprintf(' Α: IC12 paper = υβριδικό DMN/LFr -> within-DMN paper ≠ καθαρό NeuroMark DMN\n');
fprintf(' Β: paper: "10-12 if not treated as a false positive" (σελ.10)\n');
fprintf(' Γ: σκέλη β/γ σε μικρό n -> μη συμπερασματικά\n');

Tb=table((1:NSUB)',wpre,wpost,wD,epre,epost,eD,dBDI,dZung,dMAD,grp, ...
 'VariableNames',{'sub','wDMN_pre','wDMN_post','wDMN_d','DMNECN_pre','DMNECN_post','DMNECN_d','dBDI','dZung','dMADRS','group'});
writetable(Tb,fullfile(ROOT,'repro1012_full.csv'));
fprintf('\nΑρχείο: repro1012_full.csv\n');

function o=ternary(c,a,b),if c,o=a;else,o=b;end,end
