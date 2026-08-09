%% tost_ancova.m - CORRECTED covariate-adjusted TOST, Study 1
% Fixes over tost_study1_covar.m:
%  (1) single GLM y ~ group + age + sex + FD (not two-step residualisation)
%  (2) correct df = n - p (67, not 70)
%  (3) covariate balance check (was never done)
%  (4) raw-unit bounds reported alongside standardised (Lakens: raw preferred)
%  (5) leave-one-out influence
clear; clc;
ROOT='.';
PP=fullfile(ROOT,'output72','nmark72_postprocess_results');
n=72; nDep=51; ECN=91:93; DMN=94:101; A=0.05;

FNC=nan(105,105,n);
for i=1:n
    s=load(fullfile(PP,sprintf('nmark72_post_process_sub_%03d.mat',i)));
    M=squeeze(s.fnc_corrs); M(isnan(M))=0; FNC(:,:,i)=M;
end
grp=[ones(nDep,1); zeros(n-nDep,1)];
P=readtable(fullfile(ROOT,'participants_study1.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
F=readtable(fullfile(ROOT,'mean_fd_study1.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
[tf,loc]=ismember(P.participant_id,F.participant_id); assert(all(tf));
age=P.age; sex=double(strcmp(string(P.gender),'m')); fd=F.mean_fd(loc);
assert(numel(age)==n && numel(fd)==n);

mW=triu(true(numel(DMN)),1); sc=nan(n,2);
for i=1:n
    M=FNC(:,:,i); b1=M(DMN,DMN); sc(i,1)=mean(b1(mW));
    b2=M(DMN,ECN); sc(i,2)=mean(b2(:));
end
lab={'within-DMN','DMN-ECN'};
fprintf('========== A. COVARIATE BALANCE (never checked before) ==========\n');
d1=grp==1; c1=grp==0;
[~,pa,~,sa]=ttest2(age(d1),age(c1));
fprintf('age : dep %.1f+-%.1f  con %.1f+-%.1f  t(%d)=%+.2f p=%.3f\n', ...
    mean(age(d1)),std(age(d1)),mean(age(c1)),std(age(c1)),sa.df,sa.tstat,pa);
[~,pf,~,sf]=ttest2(fd(d1),fd(c1));
fprintf('FD  : dep %.4f+-%.4f con %.4f+-%.4f t(%d)=%+.2f p=%.3f\n', ...
    mean(fd(d1)),std(fd(d1)),mean(fd(c1)),std(fd(c1)),sf.df,sf.tstat,pf);
o=[sum(sex(d1)) sum(~sex(d1)); sum(sex(c1)) sum(~sex(c1))];
e=sum(o,2)*sum(o,1)/sum(o(:)); x2=sum((o-e).^2./e,'all'); px=1-chi2cdf(x2,1);
fprintf('sex : dep %dm/%df  con %dm/%df  chi2(1)=%.2f p=%.3f\n', ...
    o(1,1),o(1,2),o(2,1),o(2,2),x2,px);
if any([pa pf px]<.05)
    fprintf('>> WARNING: imbalanced covariate present. Adjustment is NOT cosmetic.\n');
else
    fprintf('>> Covariates balanced; adjustment expected to change little.\n');
end

fprintf('\n========== B. ANCOVA-based TOST ==========\n');
X=[ones(n,1) grp age sex fd]; p_par=size(X,2); df=n-p_par;
fprintf('model: y ~ 1 + group + age + sex + FD | df = %d - %d = %d\n\n', n, p_par, df);
for k=1:2
    y=sc(:,k);
    [b,~,r]=regress(y,X);
    s2=sum(r.^2)/df; C=s2*inv(X'*X);
    bg=b(2); se=sqrt(C(2,2));
    sdres=sqrt(s2);
    sp=sqrt(((sum(d1)-1)*var(y(d1))+(sum(c1)-1)*var(y(c1)))/(n-2));
    t=bg/se; pv=2*(1-tcdf(abs(t),df));
    tc=tinv(1-A/2,df);
    fprintf('--- %s ---\n', lab{k});
    fprintf(' adjusted diff (raw) = %+.5f  SE=%.5f  t(%d)=%+.3f p=%.4f\n',bg,se,df,t,pv);
    fprintf(' 95%%CI raw [%+.5f, %+.5f]\n', bg-tc*se, bg+tc*se);
    fprintf(' d (resid SD %.4f) = %+.3f | d (pooled SD %.4f) = %+.3f\n', sdres,bg/sdres,sp,bg/sp);
    for STD=[sdres sp]
        nm=tern(STD==sdres,'residual','pooled  ');
        bb=0.20:0.05:1.00; pT=nan(size(bb));
        for i=1:numel(bb)
            del=bb(i)*STD;
            pT(i)=max(1-tcdf((bg+del)/se,df), tcdf((bg-del)/se,df));
        end
        ix=find(pT<A,1);
        fprintf(' TOST[%s SD]: smallest rejectable |d| = %s (raw bound %+.5f)\n', nm, ...
            tern(isempty(ix),'none<=1.00',sprintf('%.2f',bb(max(ix,1)))), ...
            tern(isempty(ix),NaN,bb(max(ix,1))*STD));
        for pd=[0.606 0.671]
            del=pd*STD; pt=max(1-tcdf((bg+del)/se,df), tcdf((bg-del)/se,df));
            fprintf('   paper d=%.3f -> raw %+.5f, p_TOST=%.4f %s\n', pd, del, pt, ...
                tern(pt<A,'EXCLUDED','not excluded'));
        end
    end
    fprintf('\n');
end
function o=tern(c,a,b), if c, o=a; else, o=b; end, end
