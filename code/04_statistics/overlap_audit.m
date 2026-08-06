%% overlap_audit.m
% Quantifies dependence between the 13 direction comparisons.
% Purpose: justify why only the 7 "primary" ones count, and why 8/13 is invalid.
clear; clc;
key=@(P) unique(sort(P,2),'rows');
cp=@(A,B) [reshape(repmat(A(:),1,numel(B))',[],1) repmat(B(:),numel(A),1)];
jac=@(A,B) size(intersect(A,B,'rows'),1)/size(union(A,B,'rows'),1);

fprintf('====== A. NeuroMark 1.0: pair-set overlap ======\n');
PW=[43 44 46 48 49]; PS=[43 44 48 49]; CC=26:42;
S={'postDMN-within',key(nchoosek(PW,2)); 'postDMN-within STRICT',key(nchoosek(PS,2));
   'postDMN-CC',key(cp(PW,CC));          'postDMN-CC STRICT',key(cp(PS,CC))};
fprintf('%-26s %6s\n','set','pairs');
for i=1:4, fprintf('%-26s %6d\n', S{i,1}, size(S{i,2},1)); end
fprintf('\nJaccard overlap (1 = identical):\n%-26s','');
for j=1:4, fprintf('%8d',j); end; fprintf('\n');
for i=1:4
    fprintf('%-26s',S{i,1});
    for j=1:4, fprintf('%8.2f', jac(S{i,2},S{j,2})); end
    fprintf('\n');
end
fprintf('\n-> STRICT sets are SUBSETS: %d of %d within-pairs, %d of %d CC-pairs\n', ...
    size(intersect(S{2,2},S{1,2},'rows'),1), size(S{2,2},1), ...
    size(intersect(S{4,2},S{3,2},'rows'),1), size(S{4,2},1));

fprintf('\n====== B. NeuroMark 2.2 primary: shared networks ======\n');
DMN=94:101; ECN=91:93;
W=key(nchoosek(DMN,2)); E=key(cp(DMN,ECN));
fprintf('within-DMN pairs=%d, DMN-ECN pairs=%d, shared pairs=%d\n', ...
    size(W,1), size(E,1), size(intersect(W,E,'rows'),1));
fprintf('BUT both are built from the SAME 8 DMN networks (94-101).\n');

fprintf('\n====== C. v25: identical pairs, identical subjects ======\n');
fprintf('Same 28 within-DMN + 24 DMN-ECN pairs. Same 72 scans.\n');
fprintf('Only difference: fMRIPrep version. Jaccard = 1.00 by construction.\n');

fprintf('\n====== D. Subject overlap between studies ======\n');
fprintf('Paper: "Subsamples were derived from the major sample of 51 patients".\n');
fprintf('-> Study 2 (n=29) subset of Study 1 depressed (n=51): %.0f%% overlap\n', 100*29/51);
fprintf('-> Study 2 PRE scans ARE the Study 1 scans for those patients.\n');

fprintf('\n====== VERDICT ======\n');
fprintf('13 comparisons != 13 independent tests.\n');
fprintf(' - 4 nm1.0 rows: nested subsets of one claim (10-12)\n');
fprintf(' - 2 v25 rows: identical pairs+subjects, re-run of 2 claims\n');
fprintf(' - 7 primary: partially dependent (shared networks, shared subjects)\n');
fprintf('=> Report 3/7 with caveats. Do NOT report 8/13.\n');
