%% tost_study1_covar.m  — COVARIATE-ADJUSTED TOST (age + sex + mean FD)
%  Prespecified adjustment. Ίδια δομή με tost_study1_fixed.m, + residualisation.
%  Contrasts: C1 within-DMN (94:101), C2 DMN-ECN (94:101 x 91:93).
%  Μέθοδος: regress out [age, sex, FD] από το contrast score, TOST στα residuals.
clear; clc;

PP    = './output72/nmark72_postprocess_results';
PART  = './participants_study1.tsv';
FDF   = './mean_fd_study1.tsv';
nSub=72; nDep=51; ECN=91:93; DMN=94:101; ALPHA=0.05;

%% FNC
FNC=nan(105,105,nSub);
for i=1:nSub
    s=load(fullfile(PP,sprintf('nmark72_post_process_sub_%03d.mat',i)));
    m=squeeze(s.fnc_corrs); m(isnan(m))=0; FNC(:,:,i)=m;
end
grp=[ones(nDep,1);zeros(nSub-nDep,1)]; dep=grp==1; con=grp==0;

%% covariates
P=readtable(PART,'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
F=readtable(FDF ,'FileType','text','Delimiter','\t','TreatAsEmpty',{'n/a'});
% ευθυγράμμιση κατά participant_id
[~,ia]=ismember(P.participant_id, arrayfun(@(k)sprintf('sub-%02d',k),1:72,'uni',0));
assert(all(sort(ia)==(1:72)'),'participants όχι 1..72 σε σειρά');
age = P.age;
sex = double(strcmp(string(P.gender),'m'));   % m=1, f=0
[tf,loc]=ismember(P.participant_id, F.participant_id);
assert(all(tf),'FD λείπει για κάποιον');
fd = F.mean_fd(loc);
fprintf('Covariates: age [%.0f-%.0f], sex %dm/%df, FD [%.3f-%.3f]\n\n', ...
    min(age),max(age),sum(sex),sum(~sex),min(fd),max(fd));
X = [age, sex, fd];   % covariate matrix (χωρίς group)

%% contrast scores
scores=nan(nSub,2); maskW=triu(true(numel(DMN)),1);
for i=1:nSub
    M=FNC(:,:,i);
    b1=M(DMN,DMN); scores(i,1)=mean(b1(maskW));
    b2=M(DMN,ECN); scores(i,2)=mean(b2(:));
end
labels={'within-DMN','DMN-ECN'};

for k=1:2
    y=scores(:,k);
    % ---- residualise out covariates (όχι group) ----
    Xd=[ones(nSub,1) X];
    b=Xd\y; yr=y - Xd*b;   % residuals
    % ---- TOST στα residuals, depressed vs controls ----
    x=yr(dep); z=yr(con);
    n1=numel(x); n2=numel(z); nu=n1+n2-2;
    md=mean(x)-mean(z);
    sp=sqrt(((n1-1)*var(x)+(n2-1)*var(z))/nu);
    se=sp*sqrt(1/n1+1/n2);
    d=md/sp; t=md/se; p=2*(1-tcdf(abs(t),nu));
    tcrit=tinv(1-ALPHA/2,nu); dLo=(md-tcrit*se)/sp; dHi=(md+tcrit*se)/sp;

    fprintf('============ %s (ADJUSTED age+sex+FD) ============\n',labels{k});
    fprintf('mean diff (resid) %+.4f | t(%d)=%+.3f | p=%.4f\n',md,nu,t,p);
    fprintf('Cohen d %+.3f  95%%CI [%+.3f,%+.3f]\n',d,dLo,dHi);

    fprintf('TOST:\n%8s %10s %s\n','bound d','p_TOST','equiv?');
    bounds=0.30:0.05:1.00; pT=nan(size(bounds));
    for bb=1:numel(bounds)
        raw=bounds(bb)*sp;
        p1=1-tcdf((md+raw)/se,nu); p2=tcdf((md-raw)/se,nu);
        pT(bb)=max(p1,p2);
        fprintf('%8.2f %10.4f   %s\n',bounds(bb),pT(bb),ternary(pT(bb)<ALPHA,'YES','no'));
    end
    idx=find(pT<ALPHA,1);
    if isempty(idx)
        fprintf('>> Δεν απορρίπτεται ούτε d=%.2f.\n\n',bounds(end));
    else
        fprintf('>> Μικρότερο απορριπτέο |d| >= %.2f (adjusted).\n\n',bounds(idx));
    end
end

fprintf('ΣΗΜΕΙΩΣΗ: πλήρες prespecified adjustment (age, sex, mean FD).\n');
fprintf('FD από ΤΟ ΙΔΙΟ derivative (fMRIPrep 21.0.2) με τα FNC.\n');

function o=ternary(c,a,b),if c,o=a;else,o=b;end,end
