%% table6_full.m
% ΟΛΟΙ οι 17 ισχυρισμοί δυναμικής του paper (Table 6), Study 2.
% Για κάθε ΑΝΤΙΣΤΟΙΧΙΣΙΜΟ ισχυρισμό: διπλό κριτήριο ξεχωριστά ->
%   (1) ΚΑΤΕΥΘΥΝΣΗ: ίδιο πρόσημο με paper; (ανεξαρτήτως στατιστικής)
%   (2) ΣΤΑΤΙΣΤΙΚΗ: paired t-test, p/CI
% Για τους ΜΗ αντιστοιχίσιμους: ρητά "εκτός εμβέλειας NeuroMark triple-network".
%
% ΒΑΣΗ: NeuroMark 2.2. DMN=94-101, ECN=91-93. (SALIENCE: το paper ΔΕΝ έχει.)
% ΑΝΤΙΣΤΟΙΧΙΣΗ IC paper (Table 5): ΟΝΟΜΑΣΤΙΚΗ, όχι χωρικά επικυρωμένη.

clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
FNCDIR=fullfile(ROOT,'output_study2','nmark_s2_postprocess_results');
NSUB=29; DMN=94:101; ECN=91:93;

% --- FNC (index 2i-1=pre, 2i=post) ---
Z=nan(58,105,105);
for f=1:58
    S=load(fullfile(FNCDIR,sprintf('nmark_s2_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end
pre=Z(1:2:end,:,:); post=Z(2:2:end,:,:);

% --- ομάδες ---
Tc=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
grp=string(Tc.group);
G.NT=find(grp=="depr_no_treatment"); G.CBT=find(grp=="depr_cbt"); G.NFB=find(grp=="depr_nfb");
G.TR=[G.CBT;G.NFB];

% --- category averagers ---
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
catmean=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
persubj=@(P) arrayfun(@(s) catmean(squeeze(post(s,:,:)),P)-catmean(squeeze(pre(s,:,:)),P), 1:NSUB)';
wD=persubj(wP); eD=persubj(eP);

% ================== ΟΙ 17 ΙΣΧΥΡΙΣΜΟΙ TABLE 6 ==================
% {pair, IC-labels(Table5), ομάδα, paper t, κατηγορία-μας, δεδομένα-μας}
% κατηγορία: 'wDMN' | 'DMNECN' | 'OUT' (εκτός) | 'HALF' (μερικώς)
C = {
 % NT (5)
 '3-17','OccP-?','NT',+2.21,'OUT',[]
 '7-11','RFr-ECN','NT',+3.75,'OUT',[]
 '7-17','RFr-?','NT',+2.58,'OUT',[]
 '10-12','DMN-DMN/LFr','NT',+2.21,'wDMN',wD
 '10-14','DMN-?','NT',-2.34,'HALF',[]
 % combined TR (5)
 '1-3','mVis-OccP','TR',-3.71,'OUT',[]
 '5-13','AN-SMN','TR',-2.61,'OUT',[]
 '11-16','ECN-DMN','TR',-2.44,'DMNECN',eD
 '14-16','?-DMN','TR',-2.48,'HALF',[]
 '15-17','LFr-?','TR',+2.21,'OUT',[]
 % CBT (5)
 '1-3','mVis-OccP','CBT',-2.35,'OUT',[]
 '5-11','AN-ECN','CBT',-3.53,'OUT',[]
 '5-13','AN-SMN','CBT',-2.39,'OUT',[]
 '14-16','?-DMN','CBT',-2.85,'HALF',[]
 '15-17','LFr-?','CBT',+2.50,'OUT',[]
 % NFB (3)
 '1-3','mVis-OccP','NFB',-3.00,'OUT',[]
 '11-16','ECN-DMN','NFB',-3.35,'DMNECN',eD
 '13-14','SMN-?','NFB',+3.26,'OUT',[]
};

fprintf('============ TABLE 6: ΟΛΟΙ ΟΙ 17 ΙΣΧΥΡΙΣΜΟΙ ============\n');
fprintf('Κανόνας: paper t>0 => ΜΕΙΩΣΗ (pre>post)· t<0 => ΑΥΞΗΣΗ.\n');
fprintf('Δικό μας πρόσημο Δz: + => αύξηση, - => μείωση.\n\n');

nIn=0; nAgree=0; nSig=0;
for i=1:size(C,1)
    pair=C{i,1}; lab=C{i,2}; gname=C{i,3}; pt=C{i,4}; cat=C{i,5}; data=C{i,6};
    paperdir = ternary(pt>0,'ΜΕΙΩΣΗ','ΑΥΞΗΣΗ');   % t>0: pre>post => μείωση
    fprintf('[%s %s | %s] paper: %s (t=%+.2f)\n', pair, lab, gname, paperdir, pt);
    if strcmp(cat,'OUT')
        fprintf('   -> ΕΚΤΟΣ εμβέλειας NeuroMark triple-network (%s). Μη ελέγξιμο.\n\n', lab);
        continue;
    end
    if strcmp(cat,'HALF')
        fprintf('   -> ΜΗ ΑΝΤΙΣΤΟΙΧΙΣΙΜΟ: το IC "?" δεν έχει ονομασία (Table 5). Μη ελέγξιμο.\n\n');
        continue;
    end
    % αντιστοιχίσιμο -> διπλό κριτήριο
    idx=G.(gname); d=data(idx);
    mymean=mean(d);
    mydir = ternary(mymean<0,'ΜΕΙΩΣΗ','ΑΥΞΗΣΗ');
    agree = strcmp(mydir,paperdir);
    [~,p,ci,st]=ttest(d);
    nIn=nIn+1; nAgree=nAgree+agree; nSig=nSig+(p<.05);
    fprintf('   (1) ΚΑΤΕΥΘΥΝΣΗ: εσύ %s (mean Δz=%+.4f) -> %s\n', mydir, mymean, ternary(agree,'ΣΥΜΦΩΝΕΙ','ΔΙΑΦΩΝΕΙ'));
    fprintf('   (2) ΣΤΑΤΙΣΤΙΚΗ : t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f] -> %s\n\n', ...
        st.df,st.tstat,p,ci(1),ci(2), ternary(p<.05,'σημαντικό','ΜΗ σημαντικό'));
end

fprintf('============ ΣΥΝΟΨΗ ============\n');
fprintf('Σύνολο ισχυρισμών Table 6: 17\n');
fprintf('Αντιστοιχίσιμοι σε NeuroMark triple-network: %d\n', nIn);
fprintf('  εκ των οποίων συμφωνούν σε ΚΑΤΕΥΘΥΝΣΗ: %d/%d\n', nAgree, nIn);
fprintf('  εκ των οποίων ΣΤΑΤΙΣΤΙΚΑ σημαντικοί: %d/%d\n', nSig, nIn);
fprintf('Μη αντιστοιχίσιμοι (εκτός/χωρίς ονομασία): %d\n', 17-nIn);
fprintf('\nΕΥΡΗΜΑ: μόνο %d/17 ισχυρισμοί δυναμικής αφορούν καν τα triple-network\n', nIn);
fprintf('δίκτυα (DMN/ECN)· οι υπόλοιποι είναι visual/audial/SMN/frontoparietal.\n');
fprintf('ΕΠΙΦΥΛΑΞΗ: αντιστοίχιση ονομαστική· IC12 υβριδικό DMN/LFr· 2.2 δεν διαχωρίζει posterior.\n');

function o=ternary(c,a,b),if c,o=a;else,o=b;end,end
