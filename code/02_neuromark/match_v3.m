%% Spatial matching v3 - PROPER normalization + template-core comparison
%  Fixes: z-score both maps, compare where TEMPLATE is strong (network core),
%  use Spearman (robust to scale), report clear r per IC.
clear; clc;

DDIR = './output_dataica20';
ddICA = fullfile(DDIR, 'dataica20_agg__component_ica_.nii');
rNM = '<MATLAB_ROOT>/GIFT/gift-master/GroupICAT/icatb/icatb_templates/rNeuromark_fMRI_2.2_modelorder-multi.nii';

if ~exist(rNM,'file')
    error('Resliced NeuroMark not found - run match_v2 first to create it');
end

fprintf('Loading resliced NeuroMark (105, already in DD space)...\n');
VrNM = icatb_spm_vol(rNM);
nNM = numel(VrNM);
fprintf('Loading data-driven ICs (20)...\n');
Vdd = icatb_spm_vol(ddICA);
nDD = numel(Vdd);

% Load all into matrices
nm = zeros(prod(VrNM(1).dim), nNM);
for k=1:nNM, d=icatb_spm_read_vols(VrNM(k)); nm(:,k)=d(:); end
dd = zeros(prod(Vdd(1).dim), nDD);
for j=1:nDD, d=icatb_spm_read_vols(Vdd(j)); dd(:,j)=d(:); end

% Domain labels
dom = strings(nNM,1);
dom(1:13)="CB"; dom(14:19)="VI-OT"; dom(20:25)="VI-OC"; dom(26:36)="PL";
dom(37:39)="SC-EH"; dom(40:45)="SC-ET"; dom(46:54)="SC-BG"; dom(55:68)="SM";
dom(69:75)="HC-IT"; dom(76:80)="HC-TP"; dom(81:90)="HC-FR";
dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";

fprintf('Computing PROPER spatial match...\n');
fprintf('(z-score both, compare at template-core voxels, Spearman)\n\n');

bestCorr=zeros(nDD,1); bestDom=strings(nDD,1); bestNM=zeros(nDD,1); top3=cell(nDD,1);

for j=1:nDD
    ddj = dd(:,j);
    % z-score the DD map over nonzero voxels
    nz = ddj~=0 & ~isnan(ddj);
    ddz = zeros(size(ddj));
    ddz(nz) = (ddj(nz)-mean(ddj(nz)))/std(ddj(nz));

    corrs = zeros(nNM,1);
    for k=1:nNM
        nmk = nm(:,k);
        % template core = top voxels of this NM network (strong positive)
        valid = ~isnan(nmk) & nmk~=0;
        if sum(valid)<100, continue; end
        thr = prctile(nmk(valid), 75);      % top quartile of template = network core
        core = valid & (nmk>=thr);
        if sum(core)<50, continue; end
        % correlate DD (z) with NM at core voxels
        a = ddz(core); b = nmk(core);
        v = ~isnan(a)&~isnan(b);
        if sum(v)>30
            corrs(k) = corr(a(v), b(v), 'type','Spearman');
        end
    end
    [sc,si]=sort(corrs,'descend');
    bestCorr(j)=sc(1); bestDom(j)=dom(si(1)); bestNM(j)=si(1);
    top3{j}=sprintf('%s#%d(%.2f), %s#%d(%.2f), %s#%d(%.2f)', ...
        dom(si(1)),si(1),sc(1), dom(si(2)),si(2),sc(2), dom(si(3)),si(3),sc(3));
end

fprintf('============ IC -> NEUROMARK (v3, proper) ============\n');
fprintf('%-6s %-8s %-7s  %s\n','dd-IC','best','r','top-3');
for j=1:nDD
    flag=''; if bestCorr(j)<0.15, flag=' <-- weak'; end
    fprintf('IC%02d   %-8s %.3f%s   %s\n', j, bestDom(j), bestCorr(j), flag, top3{j});
end

fprintf('\n=== KEY: our identified networks - are they right? ===\n');
myID = containers.Map({6,12,14,18,1,9}, {'DMN','ECN','ECN','ECN','SAL','SAL'});
ks = cell2mat(myID.keys);
for ii=1:numel(ks)
    c = ks(ii);
    claimed = myID(c);
    actual = bestDom(c);
    match = ''; if strcmp(claimed,actual), match=' OK'; else, match=' <-- MISMATCH!'; end
    fprintf('IC%02d: I said %s | best-match %s (r=%.2f)%s\n', c, claimed, actual, bestCorr(c), match);
end
save(fullfile(DDIR,'match_v3.mat'),'bestCorr','bestDom','bestNM');
