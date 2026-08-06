%% table3_full.m
% ΟΛΑ τα 8 effects του paper (Table 3), Study 1: depressed (sub-01..51) vs controls (sub-52..72).
% BETWEEN-GROUP (independent t-test), ΟΧΙ within-subject.
% Διπλό κριτήριο ξεχωριστά:
%   (1) ΚΑΤΕΥΘΥΝΣΗ: ποια ομάδα έχει μεγαλύτερη συνδεσιμότητα -> ίδια με paper;
%   (2) ΣΤΑΤΙΣΤΙΚΗ: independent t-test (51 vs 21), p/CI.
% Για μη αντιστοιχίσιμα: ρητά "εκτός εμβέλειας NeuroMark triple-network".
%
% ΒΑΣΗ: NeuroMark 2.2. DMN=94-101, ECN=91-93. (SALIENCE/LFr/RFr: το paper τα έχει ως IC, εμείς όχι.)
% ΑΝΤΙΣΤΟΙΧΙΣΗ IC paper: ΟΝΟΜΑΣΤΙΚΗ (Table 2), όχι χωρικά επικυρωμένη.
% ΠΡΟΣΟΧΗ: fnc_corrs = Fisher-z (τιμές >1 αναμενόμενες).

clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
FNCDIR=fullfile(ROOT,'output72_v25','nmark72v25_postprocess_results');
DMN=94:101; ECN=91:93;
DEP=1:51; HC=52:72;   % index -> group

% --- FNC ---
Z=nan(72,105,105);
for f=1:72
    S=load(fullfile(FNCDIR,sprintf('nmark72v25_post_process_sub_%03d.mat',f)));
    Z(f,:,:)=squeeze(S.fnc_corrs);
end

% --- category averagers ---
[di,dj]=find(triu(true(numel(DMN)),1)); wP=[DMN(di)' DMN(dj)'];
[ei,ej]=ndgrid(DMN,ECN); eP=[ei(:) ej(:)];
catmean=@(M,P) mean(arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1)));
catvec=@(P) arrayfun(@(s) catmean(squeeze(Z(s,:,:)),P), 1:72)';
wV=catvec(wP); eV=catvec(eP);

% ================== ΤΑ 8 EFFECTS TABLE 3 ==================
% {pair, δίκτυα, t_paper, κατεύθυνση_paper, κατηγορία-μας, δεδομένα}
% κατεύθυνση paper: 'HC>depr' (t>0, controls υψηλότερα) ή 'depr>HC' (t<0)
C = {
 '1-9','DMN-LFr',-2.93,'depr>HC','OUT',[]
 '1-16','DMN-DMN',+2.59,'HC>depr','wDMN',wV
 '2-20','RFr-Cer',-2.13,'depr>HC','OUT',[]
 '5-8','mVis-AN',-2.32,'depr>HC','OUT',[]
 '5-17','mVis-LN',+1.89,'HC>depr(n/s)','OUT',[]
 '9-16','LFr-DMN',-2.97,'depr>HC','OUT',[]
 '11-13','DMN-ECN',-2.34,'depr>HC','DMNECN',eV
 '11-17','DMN-LN',-2.13,'depr>HC','OUT',[]
};

fprintf('============ TABLE 3 — v25 SENSITIVITY (Study 1) ============\n');
fprintf('depressed n=%d, controls n=%d\n', numel(DEP), numel(HC));
fprintf('Κανόνας paper: t>0 => HC>depr (controls υψηλότερα)· t<0 => depr>HC.\n\n');

nIn=0; nAgree=0; nSig=0;
for i=1:size(C,1)
    pair=C{i,1}; lab=C{i,2}; pt=C{i,3}; pdir=C{i,4}; cat=C{i,5}; data=C{i,6};
    fprintf('[%s %s] paper: %s (t=%+.2f)\n', pair, lab, pdir, pt);
    if strcmp(cat,'OUT')
        fprintf('   -> ΕΚΤΟΣ εμβέλειας NeuroMark triple-network (%s). Μη ελέγξιμο.\n\n', lab);
        continue;
    end
    d=data(DEP); h=data(HC);
    md=mean(d); mh=mean(h);
    mydir = ternary(mh>md,'HC>depr','depr>HC');
    paperdir_clean = ternary(pt>0,'HC>depr','depr>HC');
    agree = strcmp(mydir,paperdir_clean);
    [~,p,ci,st]=ttest2(d,h);
    nIn=nIn+1; nAgree=nAgree+agree; nSig=nSig+(p<.05);
    fprintf('   depr mean=%+.4f, HC mean=%+.4f\n', md, mh);
    fprintf('   (1) ΚΑΤΕΥΘΥΝΣΗ: εσύ %s -> %s\n', mydir, ternary(agree,'ΣΥΜΦΩΝΕΙ','ΔΙΑΦΩΝΕΙ'));
    fprintf('   (2) ΣΤΑΤΙΣΤΙΚΗ : t(%d)=%+.2f p=%.3f CI[%+.3f,%+.3f] -> %s\n\n', ...
        st.df,st.tstat,p,ci(1),ci(2), ternary(p<.05,'σημαντικό','ΜΗ σημαντικό'));
end

fprintf('============ ΣΥΝΟΨΗ ============\n');
fprintf('Σύνολο effects Table 3: 8\n');
fprintf('Αντιστοιχίσιμα σε NeuroMark triple-network: %d\n', nIn);
fprintf('  συμφωνούν σε ΚΑΤΕΥΘΥΝΣΗ: %d/%d\n', nAgree, nIn);
fprintf('  ΣΤΑΤΙΣΤΙΚΑ σημαντικά (uncorrected p<.05): %d/%d\n', nSig, nIn);
fprintf('Μη αντιστοιχίσιμα (LFr/RFr/Cer/visual/audial/language): %d\n', 8-nIn);
fprintf('\nΕΠΙΦΥΛΑΞΗ: αντιστοίχιση ονομαστική· IC1/IC16 του paper ≠ επικυρωμένα NeuroMark DMN·\n');
fprintf('2.2 δεν διαχωρίζει posterior· fnc=Fisher-z.\n');

function o=ternary(c,a,b),if c,o=a;else,o=b;end,end
