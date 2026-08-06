%% direction_audit.m
% Descriptive level, tested: does DIRECTION agreement exceed coin-flip (50%)?
% Rationale: if the paper's effects were real and our pipeline measures the
% same construct, sign agreement should be well above 50% even when
% individual tests are underpowered. ~50% is what shared-noise predicts.
% NO data loading - these are results already obtained.
clear; clc;
% {label, agrees(1/0), block}
R = {
 % --- PRIMARY, NeuroMark 2.2 (independent claims) ---
 'S1 1-16 within-DMN (dep vs HC)',      0, 'primary'
 'S1 11-13 DMN-ECN (dep vs HC)',        1, 'primary'
 'S2 10-12 within-DMN, NT',             0, 'primary'
 'S2 11-16 DMN-ECN, TR',                0, 'primary'
 'S2 11-16 DMN-ECN, NFB',               0, 'primary'
 'S2 baseline wDMN -> dZung, NT',       1, 'primary'
 'S2 dwDMN -> dMADRS, TR',              1, 'primary'
 % --- SENSITIVITY: v25 preprocessing (same claims, re-run) ---
 'S1 1-16 within-DMN [v25]',            1, 'v25'
 'S1 11-13 DMN-ECN [v25]',              1, 'v25'
 % --- SENSITIVITY: NeuroMark 1.0 (same claim, 4 definitions) ---
 'S2 postDMN-within [nm1.0]',           1, 'nm10'
 'S2 postDMN-CC [nm1.0]',               1, 'nm10'
 'S2 postDMN-within STRICT [nm1.0]',    0, 'nm10'
 'S2 postDMN-CC STRICT [nm1.0]',        1, 'nm10'
};
lab=R(:,1); ag=cell2mat(R(:,2)); blk=string(R(:,3));
fprintf('====== DIRECTION AUDIT (descriptive level, tested) ======\n');
fprintf('H0: sign agreement with paper = 50%% (coin flip)\n\n');
for i=1:numel(lab)
    fprintf(' %-38s %s\n', lab{i}, tern(ag(i),'AGREE','disagree'));
end
fprintf('\n%-14s %6s %6s %8s %10s %s\n','block','k','n','prop','exp(50%)','p(binom,2-sided)');
B=["primary","v25","nm10"];
for b=B
    m=blk==b; k=sum(ag(m)); n=sum(m);
    p=binom2(k,n);
    fprintf('%-14s %6d %6d %8.2f %10.1f %10.3f\n', b, k, n, k/n, n/2, p);
end
k=sum(ag); n=numel(ag);
fprintf('%-14s %6d %6d %8.2f %10.1f %10.3f\n','ALL(non-indep)',k,n,k/n,n/2,binom2(k,n));

fprintf('\n--- INTERPRETATION ---\n');
kp=sum(ag(blk=="primary")); np=sum(blk=="primary");
fprintf('Primary set: %d/%d (%.0f%%) vs 50%% expected. p=%.3f\n', kp,np,100*kp/np,binom2(kp,np));
fprintf('=> Sign agreement is %s from coin-flip.\n', ...
    tern(binom2(kp,np)<.05,'DISTINGUISHABLE','INDISTINGUISHABLE'));
fprintf('\nCAVEATS (must be stated):\n');
fprintf(' 1. Comparisons are NOT independent (same subjects, overlapping networks).\n');
fprintf(' 2. n is small; this test has low power. Absence of deviation from 50%%\n');
fprintf('    is consistent with no shared signal, but does not prove it.\n');
fprintf(' 3. v25 and nm1.0 blocks RE-TEST the same claims -> cannot be pooled.\n');
fprintf(' 4. Sign of a near-zero effect is essentially random by construction.\n');

function p=binom2(k,n)
    if n==0, p=NaN; return; end
    pk=binopdf(0:n,n,0.5);
    p=min(1,sum(pk(pk<=binopdf(k,n,0.5)+1e-12)));
end
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
