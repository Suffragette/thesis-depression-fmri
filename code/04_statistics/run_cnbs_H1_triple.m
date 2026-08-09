%% H1 (CONFIRMATORY): Triple-network NBS (Zalesky 2010, extent-based), two-tailed, FWER
%  Networks: ECN (91-93) + DMN (94-101) + Salience (102-105) = components 91:105
%  72 subjects (51 depr + 21 control). Prespecified analysis (no public timestamp).
clear; clc;

OUT  = './output72';
PP   = fullfile(OUT, 'nmark72_postprocess_results');
WORK = './nbs_work72_H1';
if ~exist(WORK,'dir'); mkdir(WORK); end
nSub = 72; nComp = 105;

% Triple-network component indices (verified from Neuromark_fMRI_2.2 labels)
TRIPLE = 91:105;                 % 15 networks (ECN+DMN+Salience)
nTri = numel(TRIPLE);

%% 1) Load 72 FNC, keep ONLY triple-network submatrix (15 x 15 x 72)
FNC = zeros(nTri, nTri, nSub);
for i = 1:nSub
    s = load(fullfile(PP, sprintf('nmark72_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs);        % 105 x 105
    m(isnan(m)) = 0;
    FNC(:,:,i) = m(TRIPLE, TRIPLE);  % keep 91:105 block
end
fprintf('H1 triple-network FNC: %d x %d x %d (ECN+DMN+Salience)\n', size(FNC));

%% 2) Design (same as full analysis, order sub-01..72)
group = [ones(51,1); zeros(21,1)];
age = [39;50;47;32;26;42;28;28;52;24;28;25;29;30;21;34;33;44;44;31;38;43;55;29;33;33;21;40;24;35;19;28;21;30;30;33;26;26;36;28;45;46;42;32;20;31;22;23;27;40;29;32;44;26;31;31;23;31;24;27;34;30;39;27;37;43;34;52;22;46;47;30];
sex = [1;1;0;0;0;1;0;1;0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1;0;0;0;0;0;1;0;1;0;1;0;0;0;1;0;0;0;0;0;0;0;1;0;0;0;1;0;1;0;0;0;0;1;1;0;0;0;0;0;1;0;0];
fd  = [0.0479;0.0686;0.1313;0.0746;0.0497;0.0615;0.0425;0.0516;0.1645;0.0886;0.1052;0.0846;0.1649;0.0546;0.0462;0.1084;0.0558;0.068;0.0406;0.0699;0.1122;0.2179;0.1164;0.1176;0.0844;0.0565;0.0567;0.1409;0.0476;0.0497;0.1098;0.0929;0.088;0.0582;0.1458;0.0512;0.0529;0.0537;0.0755;0.0556;0.0907;0.084;0.0619;0.0872;0.0694;0.0453;0.054;0.0543;0.1603;0.0871;0.0515;0.0572;0.1099;0.1396;0.046;0.08;0.0593;0.0533;0.0855;0.0697;0.0606;0.1127;0.1036;0.1411;0.101;0.0613;0.101;0.0873;0.1468;0.072;0.0429;0.0582];

fprintf('N=%d, depr=%d, control=%d, lengths %d/%d/%d\n', numel(group), sum(group), sum(group==0), numel(age), numel(sex), numel(fd));

X = [group, age-mean(age), sex-mean(sex), fd-mean(fd)];

%% 3) Save FNC & design as files
matfile    = fullfile(WORK, 'fnc_triple.mat');
designfile = fullfile(WORK, 'design.mat');
save(matfile, 'FNC');
save(designfile, 'X');

%% 4) NBS params - TWO-TAILED (F-test), FWER
clear UI
UI.method.ui   = 'Run NBS';
UI.test.ui     = 'F-test';          % two-tailed (both directions, as in paper)
UI.size.ui     = 'Extent';
UI.thresh.ui   = '3.1';
UI.perms.ui    = '5000';
UI.alpha.ui    = '0.05';
UI.contrast.ui = '[1 0 0 0]';       % F-test on group effect
UI.design.ui   = designfile;
UI.matrices.ui = matfile;
UI.exchange.ui = '';
UI.node_coor.ui  = '';
UI.node_label.ui = '';

global nbs
NBSrun(UI, []);

%% 5) Results
fprintf('\n========== H1 RESULT (triple-network, two-tailed, FWER) ==========\n');
if ~isempty(nbs) && isfield(nbs,'NBS') && isfield(nbs.NBS,'n') && nbs.NBS.n > 0
    fprintf('>>> SIGNIFICANT: %d subnetwork(s) survive FWER p<0.05!\n', nbs.NBS.n);
    for k = 1:nbs.NBS.n
        fprintf('    Subnetwork %d: p = %.4f, edges = %d\n', k, nbs.NBS.pval(k), nnz(nbs.NBS.con_mat{k}));
    end
    save(fullfile(WORK,'H1_result.mat'),'nbs','TRIPLE');
    fprintf('    (saved to H1_result.mat)\n');
else
    fprintf('>>> H1 NOT confirmed: no significant subnetwork (p<0.05 FWER).\n');
    fprintf('    Bezmaternykh-type effects do NOT survive strict FWER correction.\n');
    nbs_n = 0; if ~isempty(nbs)&&isfield(nbs,'NBS')&&isfield(nbs.NBS,'n'); nbs_n=nbs.NBS.n; end
    save(fullfile(WORK,'H1_result.mat'),'nbs','TRIPLE','nbs_n');
    fprintf('    (null result saved to H1_result.mat)\n');
end
fprintf('==================================================================\n');
