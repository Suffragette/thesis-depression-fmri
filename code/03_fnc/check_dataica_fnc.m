%% PHASE 4: FNC group comparison on data-driven ICs (paper-style reproduction)
%  Identified networks: DMN=IC06, ECN={12,14,18}, SAL={01,09}
clear; clc;

DDIR = './output_dataica20';
PP   = fullfile(DDIR, 'dataica20_postprocess_results');
nSub = 72;

% Identified components (from peak-coordinate anatomy)
DMN = 6;
ECN = [12 14 18];
SAL = [1 9];
NOI = [DMN ECN SAL];   % networks of interest

% Load per-subject FNC (20x20)
% find the per-subject files
d = dir(fullfile(PP,'dataica20_post_process_sub_*.mat'));
fprintf('Found %d per-subject FNC files\n', numel(d));
if numel(d)==0
    % maybe stored differently - check aggregate
    error('No per-subject FNC files found; check postprocess dir');
end

% Load first to get size
s1 = load(fullfile(PP, d(1).name));
fn = fieldnames(s1);
fprintf('Fields in per-subject file: %s\n', strjoin(fn,', '));

% Expect fnc_corrs [1 x 20 x 20]
FNC = zeros(20,20,nSub);
for i=1:nSub
    s = load(fullfile(PP, sprintf('dataica20_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs); m(isnan(m))=0;
    FNC(:,:,i)=m;
end
fprintf('Loaded FNC: %dx%dx%d\n', size(FNC));

grp = [ones(51,1); zeros(21,1)];
dep = grp==1; con = grp==0;

% Helper mean connectivity
function v = pairmean(M,A,B,isWithin)
    blk=M(A,B);
    if isWithin
        if numel(A)<2, v=NaN; return; end
        mask=triu(true(numel(A)),1); v=mean(blk(mask));
    else
        v=mean(blk(:));
    end
end

% Domain-pair scores per subject
labels={'within-ECN','within-SAL','DMN-ECN','DMN-SAL','ECN-SAL'};
defs={{ECN,ECN,true},{SAL,SAL,true},{DMN,ECN,false},{DMN,SAL,false},{ECN,SAL,false}};
scores=zeros(nSub,numel(defs));
for i=1:nSub
    M=FNC(:,:,i);
    for k=1:numel(defs)
        scores(i,k)=pairmean(M,defs{k}{1},defs{k}{2},defs{k}{3});
    end
end

fprintf('\n==== DATA-DRIVEN FNC: group comparison (51 depr vs 21 ctrl) ====\n');
fprintf('%-12s %9s %9s %8s %8s %8s  %s\n','pair','depr','ctrl','t','p','d','dir');
pvals=zeros(numel(defs),1);
for k=1:numel(defs)
    x=scores(dep,k); y=scores(con,k);
    [~,p,~,st]=ttest2(x,y);
    nx=numel(x);ny=numel(y);
    sp=sqrt(((nx-1)*var(x)+(ny-1)*var(y))/(nx+ny-2)); d=(mean(x)-mean(y))/sp;
    pvals(k)=p;
    if mean(x)>mean(y),dir='depr>ctrl';else,dir='depr<ctrl';end
    star='';if p<0.05,star='*';end
    fprintf('%-12s %9.4f %9.4f %8.3f %8.4f %8.3f  %s %s\n',labels{k},mean(x),mean(y),st.tstat,p,d,dir,star);
end

% Also test EACH individual pair among NOI (connection-wise)
fprintf('\n==== Connection-wise among networks of interest ====\n');
fprintf('%-14s %8s %8s %8s  %s\n','pair','t','p','d','dir');
allP=[];
for a=1:numel(NOI)
  for b=a+1:numel(NOI)
    ia=NOI(a); ib=NOI(b);
    x=squeeze(FNC(ia,ib,dep)); y=squeeze(FNC(ia,ib,con));
    [~,p,~,st]=ttest2(x,y);
    nx=numel(x);ny=numel(y); sp=sqrt(((nx-1)*var(x)+(ny-1)*var(y))/(nx+ny-2)); d=(mean(x)-mean(y))/sp;
    if mean(x)>mean(y),dir='depr>ctrl';else,dir='depr<ctrl';end
    star='';if p<0.05,star='*';end
    fprintf('IC%02d-IC%02d       %8.3f %8.4f %8.3f  %s %s\n',ia,ib,st.tstat,p,d,dir,star);
    allP=[allP;p];
  end
end
fprintf('\nConnections p<0.05 uncorrected: %d/%d (chance ~%.1f)\n', sum(allP<0.05), numel(allP), 0.05*numel(allP));
fprintf('Bonferroni threshold (%d tests): p<%.4f -> %d significant\n', numel(allP), 0.05/numel(allP), sum(allP<0.05/numel(allP)));
