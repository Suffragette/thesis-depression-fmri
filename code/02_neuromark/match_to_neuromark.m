%% Auto-match 20 data-driven ICs to NeuroMark 2.2 templates (spatial correlation)
%  Identifies which data-driven component corresponds to DMN/ECN/Salience.
clear; clc;

DDIR = './output_dataica20';
ddICA = fullfile(DDIR, 'dataica20_agg__component_ica_.nii');   % 20 components
nmTemplate = '<MATLAB_ROOT>/GIFT/gift-master/GroupICAT/icatb/icatb_templates/Neuromark_fMRI_2.2_modelorder-multi.nii'; % 105

fprintf('Loading data-driven ICs (20)...\n');
Vdd = icatb_spm_vol(ddICA);
nDD = numel(Vdd);
fprintf('  found %d data-driven components\n', nDD);

fprintf('Loading NeuroMark template (105)...\n');
Vnm = icatb_spm_vol(nmTemplate);
nNM = numel(Vnm);
fprintf('  found %d NeuroMark networks\n', nNM);

% Reslice NeuroMark to match data-driven grid (they differ in dims)
fprintf('Reslicing NeuroMark to data-driven space...\n');
% Read data-driven volumes into matrix [voxels x 20]
dd = zeros(prod(Vdd(1).dim), nDD);
for i=1:nDD
    d = icatb_spm_read_vols(Vdd(i));
    dd(:,i) = d(:);
end

% For each NeuroMark net, resample to dd grid then correlate
% Use icatb_resizeImage-style: read NM in its space, interpolate to dd(1) space
[x,y,z] = ndgrid(1:Vdd(1).dim(1), 1:Vdd(1).dim(2), 1:Vdd(1).dim(3));
xyz1 = Vdd(1).mat * [x(:)'; y(:)'; z(:)'; ones(1,numel(x))]; % world coords of dd voxels

% NeuroMark domain labels (from Neuromark_fMRI_2.2 .txt)
ECN = 91:93; DMN = 94:101; SAL = 102:105;
dom = strings(nNM,1);
dom(1:13)="CB"; dom(14:19)="VI-OT"; dom(20:25)="VI-OC"; dom(26:36)="PL";
dom(37:39)="SC-EH"; dom(40:45)="SC-ET"; dom(46:54)="SC-BG"; dom(55:68)="SM";
dom(69:75)="HC-IT"; dom(76:80)="HC-TP"; dom(81:90)="HC-FR";
dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";

fprintf('Computing correlations (this may take a minute)...\n');
bestCorr = zeros(nDD,1); bestNM = zeros(nDD,1); bestDom = strings(nDD,1);
top3 = cell(nDD,1);

for j=1:nDD
    ddj = dd(:,j);
    corrs = zeros(nNM,1);
    for k=1:nNM
        % sample NeuroMark net k at dd world coords
        vox = Vnm(k).mat \ xyz1;              % voxel coords in NM space
        nmk = icatb_spm_sample_vol(Vnm(k), vox(1,:), vox(2,:), vox(3,:), 1)';
        % correlate (ignore zeros/NaN)
        v = ~isnan(nmk) & ~isnan(ddj);
        if sum(v)>100
            c = corr(abs(ddj(v)), abs(nmk(v)));  % abs: match magnitude patterns
            corrs(k) = c;
        end
    end
    [sc, si] = sort(corrs, 'descend');
    bestCorr(j)=sc(1); bestNM(j)=si(1); bestDom(j)=dom(si(1));
    top3{j} = sprintf('%s(%.2f), %s(%.2f), %s(%.2f)', ...
        dom(si(1)),sc(1), dom(si(2)),sc(2), dom(si(3)),sc(3));
end

fprintf('\n============ DATA-DRIVEN IC -> NEUROMARK MATCH ============\n');
fprintf('%-6s %-10s %-8s  %s\n','dd-IC','best-dom','r','top-3 matches');
for j=1:nDD
    fprintf('IC%02d   %-10s %.3f    %s\n', j, bestDom(j), bestCorr(j), top3{j});
end

fprintf('\n============ NETWORKS OF INTEREST ============\n');
fprintf('Components best-matching DMN:\n');
for j=1:nDD, if bestDom(j)=="DMN", fprintf('  IC%02d (r=%.3f)\n',j,bestCorr(j)); end; end
fprintf('Components best-matching ECN:\n');
for j=1:nDD, if bestDom(j)=="ECN", fprintf('  IC%02d (r=%.3f)\n',j,bestCorr(j)); end; end
fprintf('Components best-matching SAL:\n');
for j=1:nDD, if bestDom(j)=="SAL", fprintf('  IC%02d (r=%.3f)\n',j,bestCorr(j)); end; end

save(fullfile(DDIR,'match_results.mat'),'bestCorr','bestNM','bestDom');
fprintf('\nSaved match_results.mat\n');
