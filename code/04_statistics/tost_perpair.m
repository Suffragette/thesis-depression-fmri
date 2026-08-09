%% Per-connection TOST: is an effect of the REPORTED magnitude compatible
%  with our data, connection by connection?
%
%  Motivation: the domain-level TOST averages 28 DMN sub-pairs, which dilutes
%  any effect living in a single pair. The paper's d values refer to SINGLE
%  IC pairs. This script therefore tests each of the 105 triple-network
%  connections separately, which is the fair comparison.
%
%  Paper's reported effect sizes (from Table 3 t-values, d = t*sqrt(1/21+1/51)):
%     1-16  within-DMN   t= 2.59 -> d = 0.671
%     11-13 DMN-ECN      t=-2.34 -> d = -0.606
%     9-16  LFr-DMN      t=-2.97 -> d = -0.769
%     1-9   DMN-LFr      t=-2.93 -> d = -0.759
clear; clc;

PP    = './output72/nmark72_postprocess_results';
nSub  = 72; nDep = 51;
NOI   = 91:105;                 % ECN 91-93, DMN 94-101, SAL 102-105
ALPHA = 0.05;
D_PAPER = [0.606 0.671 0.759 0.769];   % effect sizes reported by the paper
D_REF   = 0.61;                        % smallest of them: the lenient benchmark

dom = strings(105,1); dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";

%% load
FNC = nan(105,105,nSub);
for i = 1:nSub
    s = load(fullfile(PP, sprintf('nmark72_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs); m(isnan(m))=0; FNC(:,:,i) = m;
end
grp = [ones(nDep,1); zeros(nSub-nDep,1)]; dep = grp==1; con = grp==0;
n1 = sum(dep); n2 = sum(con); nu = n1+n2-2; tcrit = tinv(1-ALPHA/2, nu);
fprintf('Loaded %d subjects (%d depressed, %d control)\n\n', nSub, n1, n2);

%% per-pair stats
rows = [];
for a = 1:numel(NOI)
  for b = a+1:numel(NOI)
    ia = NOI(a); ib = NOI(b);
    x = squeeze(FNC(ia,ib,dep)); y = squeeze(FNC(ia,ib,con));
    md = mean(x)-mean(y);
    sp = sqrt(((n1-1)*var(x)+(n2-1)*var(y))/nu);
    se = sp*sqrt(1/n1+1/n2);
    d  = md/sp;  t = md/se;  p = 2*(1-tcdf(abs(t),nu));
    dLo = (md - tcrit*se)/sp;  dHi = (md + tcrit*se)/sp;
    % smallest rejectable equivalence bound
    bnds = 0.05:0.05:1.50; sm = NaN;
    for bb = bnds
        raw = bb*sp;
        p1 = 1 - tcdf((md+raw)/se, nu);
        p2 = tcdf((md-raw)/se, nu);
        if max(p1,p2) < ALPHA, sm = bb; break; end
    end
    % is the paper-scale effect excluded by our CI?
    excl = (D_REF < dLo) || (D_REF > dHi);          % +0.61 outside CI
    exclNeg = (-D_REF < dLo) || (-D_REF > dHi);     % -0.61 outside CI
    rows = [rows; ia ib d dLo dHi p sm excl exclNeg];
  end
end

%% report: strongest pairs
[~,ord] = sort(abs(rows(:,3)),'descend');
fprintf('=== 10 strongest connections (by |d|) ===\n');
fprintf('%-14s %7s %19s %8s %8s  %s\n','pair','d','95%% CI','p','min|d|','d=+/-0.61 outside CI?');
for k = 1:10
    r = rows(ord(k),:);
    fprintf('%s%02d-%s%02d %7.3f  [%+.3f, %+.3f] %8.4f %8s  %s / %s\n', ...
        dom(r(1)),r(1), dom(r(2)),r(2), r(3), r(4), r(5), r(6), ...
        smallstr(r(7)), yn(r(8)), yn(r(9)));
end

%% summary
fprintf('\n=== SUMMARY over all %d triple-network connections ===\n', size(rows,1));
fprintf('Connections with p<0.05 uncorrected : %d  (chance ~%.1f)\n', sum(rows(:,6)<0.05), 0.05*size(rows,1));
fprintf('Largest |d| observed                : %.3f\n', max(abs(rows(:,3))));
fprintf('Mean |d|                            : %.3f\n', mean(abs(rows(:,3))));
fprintf('\nCompatibility with the paper''s reported magnitudes:\n');
for dp = D_PAPER
    nExcl = sum( (dp < rows(:,4)) | (dp > rows(:,5)) );
    nExclN= sum( (-dp < rows(:,4)) | (-dp > rows(:,5)) );
    fprintf('  d=%+.3f excluded by CI in %3d/%d connections | d=%+.3f in %3d/%d\n', ...
        dp, nExcl, size(rows,1), -dp, nExclN, size(rows,1));
end
fprintf('\nMedian smallest rejectable |d| across connections: %.2f\n', median(rows(~isnan(rows(:,7)),7)));
fprintf('(i.e. typically we can exclude effects larger than about this)\n');

save('./tost_perpair_results.mat','rows','dom','NOI');
fprintf('\nSaved tost_perpair_results.mat\n');

function s = yn(v),  if v, s='YES'; else, s='no'; end, end
function s = smallstr(v), if isnan(v), s='>1.50'; else, s=sprintf('%.2f',v); end, end
