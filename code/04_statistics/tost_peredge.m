%% tost_peredge.m - PER-EDGE equivalence testing (corrects the denominator problem)
% Problem with previous TOST: we tested the MEAN of 28 pairs; the paper tested
% ONE pair. Var(mean) = (s^2/n)[1+(n-1)rho] -> different quantity entirely.
% A single-edge effect of 0.14 becomes ~0.005 in a 28-edge mean: undetectable.
% Fix: run TOST on each edge separately, same SESOI, report how many are excluded.
clear; clc;
ROOT='.';
DMN=94:101; ECN=91:93; A=0.05;
[i1,i2]=find(triu(true(numel(DMN)),1)); W=[DMN(i1)' DMN(i2)'];
[e1,e2]=ndgrid(DMN,ECN); E=[e1(:) e2(:)];

% ---- Study 1 ----
F=nan(72,size(W,1)+size(E,1)); P=[W;E];
for s=1:72
    m=load(fullfile(ROOT,'output72','nmark72_postprocess_results',sprintf('nmark72_post_process_sub_%03d.mat',s)));
    M=squeeze(m.fnc_corrs); M(isnan(M))=0;
    F(s,:)=arrayfun(@(k)M(P(k,1),P(k,2)),1:size(P,1));
end
% ---- Study 2 paired deltas ----
D=nan(29,size(P,1));
for s=1:29
    a=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results',sprintf('nmark_s2_post_process_sub_%03d.mat',2*s-1)));
    b=load(fullfile(ROOT,'output_study2','nmark_s2_postprocess_results',sprintf('nmark_s2_post_process_sub_%03d.mat',2*s)));
    Ma=squeeze(a.fnc_corrs); Mb=squeeze(b.fnc_corrs); Ma(isnan(Ma))=0; Mb(isnan(Mb))=0;
    D(s,:)=arrayfun(@(k)Mb(P(k,1),P(k,2))-Ma(P(k,1),P(k,2)),1:size(P,1));
end
T=readtable(fullfile(ROOT,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
NT=find(string(T.group)=="depr_no_treatment")';
nW=size(W,1);
fprintf('Loaded. edges: %d within-DMN + %d DMN-ECN\n\n', nW, size(E,1));
fprintf('======= STUDY 1: per-edge TOST (between-group, n=51/21) =======\n');
g=[true(51,1);false(21,1)]; nu=70;
for SES=[0.606 0.671]
    nEx=0; nSig=0; dz=nan(size(P,1),1); pT=nan(size(P,1),1);
    for k=1:size(P,1)
        x=F(g,k); y=F(~g,k);
        sp=sqrt((50*var(x)+20*var(y))/nu); se=sp*sqrt(1/51+1/21);
        md=mean(x)-mean(y); dz(k)=md/sp;
        [~,pv]=ttest2(x,y); nSig=nSig+(pv<A);
        del=SES*sp;
        pT(k)=max(1-tcdf((md+del)/se,nu), tcdf((md-del)/se,nu));
        nEx=nEx+(pT(k)<A);
    end
    fprintf('SESOI d=%.3f : edges excluded %d/%d (%.0f%%) | sig (uncorr) %d\n', ...
        SES, nEx, size(P,1), 100*nEx/size(P,1), nSig);
    fprintf('   observed |d| per edge: median %.2f  max %.2f\n', median(abs(dz)), max(abs(dz)));
end

fprintf('\n======= STUDY 2 NT: per-edge TOST (paired, n=15) =======\n');
SES=0.571; nEx=0; nSig=0; dzv=nan(nW,1);
for k=1:nW
    x=D(NT,k); s=std(x); m=mean(x); se=s/sqrt(15); dzv(k)=m/s;
    [~,pv]=ttest(x); nSig=nSig+(pv<A);
    del=SES*s;
    p=max(1-tcdf((m+del)/se,14), tcdf((m-del)/se,14));
    nEx=nEx+(p<A);
end
fprintf('SESOI dz=%.3f : edges excluded %d/%d | sig (uncorr) %d\n', SES, nEx, nW, nSig);
fprintf('   observed |dz| per edge: median %.2f  max %.2f\n', median(abs(dzv)), max(abs(dzv)));

fprintf('\n======= SCALE CHECK vs paper =======\n');
fprintf('paper 10-12: pre .45+-.15  post .31+-.18  -> raw change -0.140\n');
sdw=std(D(NT,1:nW)); mw=mean(D(NT,1:nW));
fprintf('our within-DMN edges: |raw change| median %.3f max %.3f\n', median(abs(mw)), max(abs(mw)));
fprintf('our per-edge SD of change: median %.3f (paper implies ~%.2f)\n', median(sdw), 0.165);
fprintf('our SD of the 28-edge MEAN: %.3f  <-- the wrong denominator\n', std(mean(D(NT,1:nW),2)));
fprintf('dilution factor: %.1fx\n', median(sdw)/std(mean(D(NT,1:nW),2)));
fprintf('\n=> A single-edge change of 0.140 appears as %.4f in the 28-edge mean.\n', 0.140/nW);
