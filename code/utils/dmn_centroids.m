%% dmn_centroids.m  (έκδοση χωρίς SPM — built-in NIfTI reader)
% ΑΝΤΙΚΕΙΜΕΝΙΚΟΣ ορισμός posterior vs anterior DMN, ΑΠΟΚΛΕΙΣΤΙΚΑ από NeuroMark 2.2.
% Καμία ανθρώπινη επιλογή. Centroid βάρους |z| -> πρόσημο Y = posterior/anterior.

clear; clc;
NII = './output_test/rNeuromark_fMRI_2.2_modelorder-multi.nii';
DMN = 94:101;

info = niftiinfo(NII);
vol  = niftiread(info);          % X x Y x Z x 105
A    = info.Transform.T';        % 4x4 affine (MATLAB δίνει transpose)
dim  = info.ImageSize(1:3);

[gx,gy,gz] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
% niftiinfo affine: MNI = A * [i-1; j-1; k-1; 1] (0-based)
vox = [gx(:)-1, gy(:)-1, gz(:)-1, ones(numel(gx),1)]';
mni = A * vox;

fprintf('=== DMN ICN centroids (NeuroMark 2.2, weighted by |z|) ===\n');
fprintf('affine check: MNI origin voxel(1,1,1) = %s\n', mat2str(round(mni(1:3,1))',4));
fprintf('%-6s %8s %8s %8s   %s\n','ICN','X','Y','Z','θέση');
res = zeros(numel(DMN),4);
for i = 1:numel(DMN)
    c = DMN(i);
    img = double(vol(:,:,:,c));
    w = abs(img(:)); w(isnan(w)) = 0;
    cen = (mni(1:3,:) * w) / sum(w);
    pos = ternary(cen(2) < 0, 'POSTERIOR', 'anterior');
    res(i,:) = [c cen(1) cen(2) cen(3)];
    fprintf('DMN%-3d %8.1f %8.1f %8.1f   %s\n', c, cen(1), cen(2), cen(3), pos);
end

fprintf('\n=== Sensitivity: centroid μόνο στα top-10%% |z| voxels ===\n');
fprintf('%-6s %8s   %s\n','ICN','Y_thr','συμφωνεί;');
for i = 1:numel(DMN)
    c = DMN(i);
    img = double(vol(:,:,:,c)); w = abs(img(:)); w(isnan(w))=0;
    thr = quantile(w(w>0), 0.90); m = w >= thr;
    yc = (mni(2,m) * w(m)) / sum(w(m));
    agree = ternary(sign(yc)==sign(res(i,3)), 'ναι', '*** ΟΧΙ ***');
    fprintf('DMN%-3d %8.1f   %s\n', c, yc, agree);
end

post = res(res(:,3) < 0, 1);
ante = res(res(:,3) >= 0, 1);
fprintf('\n=== ΑΠΟΤΕΛΕΣΜΑ (αυτόματο, Y<0) ===\n');
fprintf('POSTERIOR-DMN: %s\n', mat2str(post'));
fprintf('anterior-DMN : %s\n', mat2str(ante'));

save('./dmn_centroids.mat','res','post','ante');
writematrix(res, './dmn_centroids.csv');
fprintf('\nΑποθηκεύτηκε: dmn_centroids.mat / .csv\n');

function o = ternary(c,a,b), if c, o=a; else, o=b; end, end
