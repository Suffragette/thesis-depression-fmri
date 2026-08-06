%% sesoi_check.m - Does the conclusion survive the principled (Lakens) SESOI?
% Observed-d SESOI (what we used) vs minimum-detectable-d SESOI (Lakens 2018).
clear; clc;
b=0.00719; se=0.01575; df=67; sd=0.0606;      % within-DMN, ANCOVA
b2=0.00809; se2=0.01790; sd2=0.0689;          % DMN-ECN
k=sqrt(1/51+1/21); tc=tinv(0.975,70);
fprintf('Paper design: n=51/21, df=70, t_crit=%.3f\n', tc);
fprintf('Minimum DETECTABLE d in paper = %.3f * %.4f = %.4f\n\n', tc, k, tc*k);
S={'within-DMN',b,se,sd; 'DMN-ECN',b2,se2,sd2};
for i=1:2
    fprintf('--- %s ---\n', S{i,1});
    for pair={{'observed d (1-16)',0.671},{'observed d (11-13)',0.606},{'MIN DETECTABLE (Lakens)',tc*k}}
        nm=pair{1}{1}; d=pair{1}{2}; del=d*S{i,4};
        p=max(1-tcdf((S{i,2}+del)/S{i,3},df), tcdf((S{i,2}-del)/S{i,3},df));
        fprintf(' %-26s d=%.3f  p_TOST=%.4f  %s\n', nm, d, p, ...
            tern(p<0.05,'EXCLUDED','NOT excluded'));
    end
    fprintf('\n');
end
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
