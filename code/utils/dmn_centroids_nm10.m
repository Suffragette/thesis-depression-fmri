%% dmn_centroids_nm10.m
% Objective anterior vs posterior DMN in NeuroMark 1.0 (ICN 43-49).
% Same method as dmn_centroids.m for 2.2. |z|-weighted MNI centroid; sign of Y.
clear; clc;
NII = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_study2_nm10/rNeuromark_fMRI_1.0.nii';
DMN = 43:49;

info = niftiinfo(NII);
vol  = niftiread(info);
A    = info.Transform.T';
dim  = info.ImageSize(1:3);
fprintf('volumes: %d  dims: %s\n', info.ImageSize(4), mat2str(dim));

[gx,gy,gz] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
vox = [gx(:)-1, gy(:)-1, gz(:)-1, ones(numel(gx),1)]';
mni = A * vox;

fprintf('\n=== NeuroMark 1.0 DMN centroids (|z|-weighted) ===\n');
fprintf('%-7s %8s %8s %8s   %s\n','ICN','X','Y','Z','pos');
res = zeros(numel(DMN),4);
for i = 1:numel(DMN)
    c = DMN(i);
    img = double(vol(:,:,:,c)); w = abs(img(:)); w(isnan(w))=0;
    cen = (mni(1:3,:) * w) / sum(w);
    res(i,:) = [c cen(1) cen(2) cen(3)];
    fprintf('DM%-4d %8.1f %8.1f %8.1f   %s\n', c, cen(1), cen(2), cen(3), ternary(cen(2)<0,'POSTERIOR','ANTERIOR'));
end

fprintf('\n=== Sensitivity: top-10%% |z| voxels ===\n');
for i = 1:numel(DMN)
    c = DMN(i);
    img = double(vol(:,:,:,c)); w = abs(img(:)); w(isnan(w))=0;
    thr = quantile(w(w>0),0.90); m = w>=thr;
    yc = (mni(2,m)*w(m))/sum(w(m));
    fprintf('DM%-4d Y_thr=%+7.1f  %s\n', c, yc, ternary(sign(yc)==sign(res(i,3)),'agree','*** DISAGREE ***'));
end

post = res(res(:,3)<0,1); ante = res(res(:,3)>=0,1);
fprintf('\n=== RESULT (automatic, Y<0) ===\n');
fprintf('POSTERIOR-DMN: %s\n', mat2str(post'));
fprintf('ANTERIOR-DMN : %s\n', mat2str(ante'));
if isempty(ante)
    fprintf('>> NO anterior component: 1.0 also does not separate (same as 2.2).\n');
else
    fprintf('>> 1.0 DOES separate anterior/posterior. Targeted test possible.\n');
end
save('/Users/hedylamarr/Documents/MATLAB/thesis_scripts/dmn_centroids_nm10.mat','res','post','ante');

function o=ternary(c,a,b), if c, o=a; else, o=b; end, end
