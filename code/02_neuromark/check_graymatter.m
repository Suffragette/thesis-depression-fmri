%% Filter components by gray-matter prevalence (like the paper: kept 11/20)
%  For each of 20 ICs: correlation with GM vs WM vs CSF masks.
%  Component is ACCEPTED if it correlates more with GM than WM or CSF.
clear; clc;

ddICA = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_dataica20/dataica20_agg__component_ica_.nii';
Vdd = icatb_spm_vol(ddICA);
nDD = numel(Vdd);

% Find SPM tissue probability maps (TPM) - GM/WM/CSF
tpmCandidates = {
  '/Users/hedylamarr/Documents/MATLAB/spm12-main/tpm/TPM.nii'
  '/Users/hedylamarr/Documents/MATLAB/spm12/tpm/TPM.nii'
};
tpm = '';
for i=1:numel(tpmCandidates)
    if exist(tpmCandidates{i},'file'), tpm=tpmCandidates{i}; break; end
end
if isempty(tpm)
    % search
    d = dir('/Users/hedylamarr/Documents/MATLAB/**/TPM.nii');
    if ~isempty(d), tpm=fullfile(d(1).folder,d(1).name); end
end
fprintf('TPM file: %s\n', tpm);
if isempty(tpm) || ~exist(tpm,'file')
    error('TPM.nii not found - tell me and I will locate SPM tissue maps');
end

% TPM.nii has 6 volumes: 1=GM, 2=WM, 3=CSF, 4-6=skull/soft/air
Vtpm = icatb_spm_vol(tpm);
fprintf('TPM has %d tissue volumes\n', numel(Vtpm));

% Reslice TPM to DD space
WORK='/Users/hedylamarr/Documents/MATLAB/thesis_scripts/tpm_work';
if ~exist(WORK,'dir'), mkdir(WORK); end
refCopy=fullfile(WORK,'ref.nii'); copyfile(ddICA, refCopy);
tpmCopy=fullfile(WORK,'tpm.nii'); copyfile(tpm, tpmCopy);
flags=struct('mask',false,'mean',false,'interp',1,'which',1,'wrap',[0 0 0],'prefix','r');
icatb_spm_reslice(char(refCopy, tpmCopy), flags);
rtpm=fullfile(WORK,'rtpm.nii');
Vr=icatb_spm_vol(rtpm);
fprintf('Resliced TPM: %d vols, dim %s\n', numel(Vr), mat2str(Vr(1).dim));

GM=icatb_spm_read_vols(Vr(1)); GM=GM(:);
WM=icatb_spm_read_vols(Vr(2)); WM=WM(:);
CSF=icatb_spm_read_vols(Vr(3)); CSF=CSF(:);

fprintf('\n==== GM/WM/CSF prevalence per component (paper criterion) ====\n');
fprintf('%-6s %7s %7s %7s   %s\n','IC','GM','WM','CSF','verdict');
accepted=[];
for j=1:nDD
    vol=icatb_spm_read_vols(Vdd(j)); vol=abs(vol(:));  % magnitude
    v = ~isnan(vol) & vol>0;
    % weighted overlap: sum(component_intensity * tissue_prob) normalized
    gmS = sum(vol(v).*GM(v)) / sum(vol(v));
    wmS = sum(vol(v).*WM(v)) / sum(vol(v));
    csfS= sum(vol(v).*CSF(v))/ sum(vol(v));
    if gmS>wmS && gmS>csfS
        verdict='GM (accept)'; accepted=[accepted j];
    else
        verdict='artifact (reject)';
    end
    fprintf('IC%02d  %7.3f %7.3f %7.3f   %s\n', j, gmS, wmS, csfS, verdict);
end
fprintf('\nAccepted (GM-dominant): %d / 20  ->  %s\n', numel(accepted), mat2str(accepted));
fprintf('(Paper kept 11/20)\n');

% Flag our networks of interest
fprintf('\n=== Are our identified networks GM-valid? ===\n');
NOI=[6 14 1 9 12 18]; nm={'DMN','ECN','SAL','SAL','ECN','ECN'};
for i=1:numel(NOI)
    ok = ismember(NOI(i),accepted);
    fprintf('IC%02d (%s): %s\n', NOI(i), nm{i}, string(ok)*"GM-valid" + (~ok)*"ARTIFACT!");
end
save('/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_dataica20/gm_filter.mat','accepted');
