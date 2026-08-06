%% cNBS/NBS: σύγκριση depr vs control στα FNC matrices (20 άτομα pilot)
clear; clc;

OUT = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output20';
PP  = fullfile(OUT, 'nmark20_postprocess_results');
WORK = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/nbs_work';
if ~exist(WORK,'dir'); mkdir(WORK); end
nSub = 20; nComp = 105;

%% 1) Φόρτωσε τα 20 FNC matrices -> πίνακας 105 x 105 x 20
FNC = zeros(nComp, nComp, nSub);
for i = 1:nSub
    s = load(fullfile(PP, sprintf('nmark20_post_process_sub_%03d.mat', i)));
    m = squeeze(s.fnc_corrs);
    m(isnan(m)) = 0;
    FNC(:,:,i) = m;
end
fprintf('Φορτώθηκαν FNC: %d x %d x %d\n', size(FNC));

%% 2) Design matrix
group = [ones(10,1); zeros(10,1)];   % 1=depr, 0=control
age = [39;50;47;32;26;42;28;28;52;24; 32;44;26;31;31;23;31;24;27;34];
sex = [1;1;0;0;0;1;0;1;0;1; 1;0;0;0;1;0;1;0;0;0];
fd  = [0.0479;0.0686;0.1313;0.0746;0.0497;0.0615;0.0425;0.0516;0.1645;0.0886; ...
       0.0572;0.1099;0.1396;0.0460;0.0800;0.0593;0.0533;0.0855;0.0697;0.0606];
X = [group, age-mean(age), sex-mean(sex), fd-mean(fd)];

%% 3) Σώσε FNC & design ως αρχεία (το NBS τα θέλει ως paths)
matfile    = fullfile(WORK, 'fnc_matrices.mat');
designfile = fullfile(WORK, 'design.mat');
save(matfile, 'FNC');
save(designfile, 'X');

%% 4) NBS parameters (paths, όχι μεταβλητές)
clear UI
UI.method.ui   = 'Run NBS';
UI.test.ui     = 't-test';
UI.size.ui     = 'Extent';
UI.thresh.ui   = '3.1';
UI.perms.ui    = '5000';
UI.alpha.ui    = '0.05';
UI.contrast.ui = '[1 0 0 0]';       % depr > control
UI.design.ui   = designfile;
UI.matrices.ui = matfile;
UI.exchange.ui = '';
UI.node_coor.ui  = '';
UI.node_label.ui = '';

global nbs
NBSrun(UI, []);

%% 5) Αποτελέσματα
if ~isempty(nbs) && isfield(nbs,'NBS') && isfield(nbs.NBS,'n') && nbs.NBS.n > 0
    fprintf('\n>>> Βρέθηκαν %d significant subnetwork(s)!\n', nbs.NBS.n);
    for k = 1:nbs.NBS.n
        fprintf('    Subnetwork %d: p = %.4f, size = %d edges\n', ...
                k, nbs.NBS.pval(k), nnz(nbs.NBS.con_mat{k}));
    end
else
    fprintf('\n>>> Κανένα significant subnetwork (p<0.05 FWER) σε αυτό το pilot.\n');
    fprintf('    (Αναμενόμενο με N=20. Η αλυσίδα δουλεύει end-to-end.)\n');
end
