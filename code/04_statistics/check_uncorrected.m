%% DIAGNOSTIC: uncorrected connection-wise stats in triple-network
%  Answers: "is there signal where the paper found it, before strict correction?"
clear; clc;

OUT  = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output72';
PP   = fullfile(OUT, 'nmark72_postprocess_results');
nSub = 72; nComp = 105;
TRIPLE = 91:105;                 % ECN(91-93)+DMN(94-101)+Salience(102-105)
labels = {};
for c=91:93,  labels{end+1}=sprintf('ECN-%d',c); end
for c=94:101, labels{end+1}=sprintf('DMN-%d',c); end
for c=102:105,labels{end+1}=sprintf('SAL-%d',c); end
nTri = numel(TRIPLE);

% Load full FNC then extract triple block
FNC = zeros(nTri, nTri, nSub);
for i = 1:nSub
    s = load(fullfile(PP, sprintf('nmark72_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs); m(isnan(m))=0;
    FNC(:,:,i) = m(TRIPLE,TRIPLE);
end

grp = [ones(51,1); zeros(21,1)];   % 1=depr, 0=control
dep = grp==1; con = grp==0;

% Connection-wise two-sample t-test (upper triangle only)
fprintf('=== Uncorrected connection-wise t-tests (triple-network, %d nodes) ===\n', nTri);
fprintf('=== %d unique connections ===\n\n', nTri*(nTri-1)/2);
results = [];
for a = 1:nTri
  for b = a+1:nTri
    x = squeeze(FNC(a,b,dep));
    y = squeeze(FNC(a,b,con));
    [~,p,~,st] = ttest2(x,y);
    % Cohen's d
    nx=numel(x); ny=numel(y);
    sp = sqrt(((nx-1)*var(x)+(ny-1)*var(y))/(nx+ny-2));
    d = (mean(x)-mean(y))/sp;
    results = [results; a b p st.tstat d mean(x) mean(y)];
  end
end

% Sort by p-value
[~,ord] = sort(results(:,3));
results = results(ord,:);

% How many p<0.05 uncorrected?
nSig = sum(results(:,3)<0.05);
fprintf('Connections with UNCORRECTED p<0.05: %d out of %d\n', nSig, size(results,1));
fprintf('(Expected by chance alone: ~%.1f)\n\n', 0.05*size(results,1));

% FDR correction (Benjamini-Hochberg) - milder than FWER, common in older papers
pvals = results(:,3);
[ps,idx] = sort(pvals);
m = numel(ps);
fdr_thr = (1:m)'/m * 0.05;
below = ps <= fdr_thr;
if any(below)
    kmax = find(below,1,'last');
    fdr_crit = ps(kmax);
    nFDR = sum(pvals<=fdr_crit);
else
    nFDR = 0;
end
fprintf('Connections surviving FDR q<0.05 (Benjamini-Hochberg): %d\n\n', nFDR);

% Show top 15 strongest differences
fprintf('=== TOP 15 strongest group differences ===\n');
fprintf('%-10s %-10s %8s %8s %8s  %s\n','NodeA','NodeB','p','t','Cohen-d','dir');
for r = 1:min(15,size(results,1))
    a=results(r,1); b=results(r,2); p=results(r,3); t=results(r,4); d=results(r,5);
    dir = ''; if results(r,6)>results(r,7), dir='depr>ctrl'; else dir='depr<ctrl'; end
    star=''; if p<0.05, star='*'; end
    fprintf('%-10s %-10s %8.4f %8.3f %8.3f  %s %s\n', labels{a}, labels{b}, p, t, d, dir, star);
end

% Focus: DMN-DMN and DMN-ECN connections (paper's key finding)
fprintf('\n=== PAPER''S KEY DOMAINS: DMN-DMN and DMN-ECN connections ===\n');
isDMN = @(i) i>=4 && i<=11;    % DMN = positions 4-11 in triple block (comp 94-101)
isECN = @(i) i>=1 && i<=3;     % ECN = positions 1-3 (comp 91-93)
cnt_dd=0; cnt_dd_sig=0; cnt_de=0; cnt_de_sig=0;
for r=1:size(results,1)
    a=results(r,1); b=results(r,2); p=results(r,3);
    if isDMN(a)&&isDMN(b), cnt_dd=cnt_dd+1; if p<0.05,cnt_dd_sig=cnt_dd_sig+1;end; end
    if (isDMN(a)&&isECN(b))||(isECN(a)&&isDMN(b)), cnt_de=cnt_de+1; if p<0.05,cnt_de_sig=cnt_de_sig+1;end; end
end
fprintf('DMN-DMN connections: %d total, %d with p<0.05 uncorrected\n', cnt_dd, cnt_dd_sig);
fprintf('DMN-ECN connections: %d total, %d with p<0.05 uncorrected\n', cnt_de, cnt_de_sig);
fprintf('\n=== INTERPRETATION GUIDE ===\n');
fprintf('If nSig is around chance level (~%.0f) -> genuinely no signal.\n', 0.05*size(results,1));
fprintf('If nSig >> chance AND concentrated in DMN -> signal exists but does not survive FWER.\n');
