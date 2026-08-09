%% Auto-match 20 data-driven ICs to NeuroMark 2.2 - FIXED (proper SPM reslice)
clear; clc;

DDIR = './output_dataica20';
ddICA = fullfile(DDIR, 'dataica20_agg__component_ica_.nii');
nmTemplate = '<MATLAB_ROOT>/GIFT/gift-master/GroupICAT/icatb/icatb_templates/Neuromark_fMRI_2.2_modelorder-multi.nii';
WORK = fullfile(DDIR,'match_work'); if ~exist(WORK,'dir'); mkdir(WORK); end

% Copy DD as reference (target space)
refFile = fullfile(WORK,'ref_dd.nii');
copyfile(ddICA, refFile);

% Reslice NeuroMark (105) into DD space using SPM (handles affine flip + resample)
srcFile = fullfile(WORK,'nm_src.nii');
copyfile(nmTemplate, srcFile);

fprintf('Reslicing NeuroMark -> data-driven space via spm_reslice...\n');
% Build list: ref first (vol1 of DD), then all NM vols
Vref = icatb_spm_vol(refFile);
Vnm  = icatb_spm_vol(nmTemplate);
nNM = numel(Vnm); nDD = numel(icatb_spm_vol(ddICA));

% spm_reslice needs ref + sources; reslice each NM volume
% Create a 4D source containing [ref; all NM]? Simpler: reslice writing r-prefixed
flags = struct('mask',false,'mean',false,'interp',1,'which',1,'wrap',[0 0 0],'prefix','r');
% Reference must be first in list
P = char(refFile, nmTemplate);
icatb_spm_reslice(P, flags);   % writes rnm_src... actually r-prefix on 2nd file
rNM = fullfile(fileparts(nmTemplate), ['r' 'Neuromark_fMRI_2.2_modelorder-multi.nii']);
if ~exist(rNM,'file')
    % try alternate location
    d = dir(fullfile(fileparts(nmTemplate),'rNeuromark_fMRI_2.2*.nii'));
    if ~isempty(d), rNM = fullfile(d(1).folder,d(1).name); end
end
fprintf('Resliced NM: %s\n', rNM);

% Load resliced NM (now in DD space, 97x115x97 x105) and DD
VrNM = icatb_spm_vol(rNM);
fprintf('Resliced NM dims: %d %d %d (n=%d)\n', VrNM(1).dim, numel(VrNM));

Vdd = icatb_spm_vol(ddICA);
dd = zeros(prod(Vdd(1).dim), nDD);
for i=1:nDD, d=icatb_spm_read_vols(Vdd(i)); dd(:,i)=d(:); end
nm = zeros(prod(VrNM(1).dim), numel(VrNM));
for k=1:numel(VrNM), d=icatb_spm_read_vols(VrNM(k)); nm(:,k)=d(:); end

% Domain labels
dom = strings(nNM,1);
dom(1:13)="CB"; dom(14:19)="VI-OT"; dom(20:25)="VI-OC"; dom(26:36)="PL";
dom(37:39)="SC-EH"; dom(40:45)="SC-ET"; dom(46:54)="SC-BG"; dom(55:68)="SM";
dom(69:75)="HC-IT"; dom(76:80)="HC-TP"; dom(81:90)="HC-FR";
dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";

fprintf('\nComputing correlations (proper alignment)...\n');
bestCorr=zeros(nDD,1); bestDom=strings(nDD,1); top3=cell(nDD,1);
for j=1:nDD
    ddj = dd(:,j);
    corrs=zeros(nNM,1);
    for k=1:nNM
        nmk=nm(:,k);
        v = ~isnan(ddj)&~isnan(nmk)&(nmk~=0);
        if sum(v)>100, corrs(k)=corr(ddj(v),nmk(v)); end
    end
    [sc,si]=sort(corrs,'descend');
    bestCorr(j)=sc(1); bestDom(j)=dom(si(1));
    top3{j}=sprintf('%s(%.2f), %s(%.2f), %s(%.2f)',dom(si(1)),sc(1),dom(si(2)),sc(2),dom(si(3)),sc(3));
end

fprintf('\n============ IC -> NEUROMARK MATCH (fixed) ============\n');
fprintf('%-6s %-10s %-8s  %s\n','dd-IC','best','r','top-3');
for j=1:nDD
    fprintf('IC%02d   %-10s %.3f    %s\n', j, bestDom(j), bestCorr(j), top3{j});
end
fprintf('\n=== NETWORKS OF INTEREST ===\n');
for target=["DMN","ECN","SAL"]
    fprintf('%s: ', target);
    found=false;
    for j=1:nDD, if bestDom(j)==target, fprintf('IC%02d(r=%.2f) ',j,bestCorr(j)); found=true; end; end
    if ~found, fprintf('(none as best match)'); end
    fprintf('\n');
end
save(fullfile(DDIR,'match_results_v2.mat'),'bestCorr','bestDom','top3');
