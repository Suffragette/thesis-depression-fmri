%% spatial_corr.m - NeuroMark ICNs vs Smith 2009 RSN templates (MNI-aligned)
% Fixes the x-flip: rsn affine has -2 on x, NeuroMark +2.
% Method: for each NeuroMark voxel -> MNI -> inverse-map into rsn index space
%         -> trilinear sample. No voxel-wise reindexing.
% POSITIVE CONTROL: visual RSNs must match NeuroMark visual ICNs (14-25).
clear; clc;
ROOT='.';
NM=fullfile(ROOT,'output_test','rNeuromark_fMRI_2.2_modelorder-multi.nii');
RS='./PNAS_Smith09_rsn10.nii';

iN=niftiinfo(NM); vN=niftiread(iN); AN=iN.Transform.T'; dN=iN.ImageSize(1:3);
iR=niftiinfo(RS); vR=single(niftiread(iR)); AR=iR.Transform.T'; dR=iR.ImageSize(1:3);
nR=iR.ImageSize(4);
fprintf('NeuroMark %s (%d comps) | Smith %s (%d comps)\n', ...
    mat2str(dN), iN.ImageSize(4), mat2str(dR), nR);

[gx,gy,gz]=ndgrid(0:dN(1)-1, 0:dN(2)-1, 0:dN(3)-1);
mni=AN*[gx(:)';gy(:)';gz(:)';ones(1,numel(gx))];
src=AR\mni;                       % MNI -> rsn 0-based indices
si=reshape(src(1,:),dN)+1; sj=reshape(src(2,:),dN)+1; sk=reshape(src(3,:),dN)+1;
inb = si>=1 & si<=dR(1) & sj>=1 & sj<=dR(2) & sk>=1 & sk<=dR(3);
fprintf('voxels inside Smith FOV: %d / %d (%.1f%%)\n', sum(inb(:)), numel(inb), 100*mean(inb(:)));

R=nan([dN nR]);
for c=1:nR
    F=griddedInterpolant({1:dR(1),1:dR(2),1:dR(3)}, vR(:,:,:,c),'linear','none');
    tmp=nan(dN); tmp(inb)=F(si(inb),sj(inb),sk(inb)); R(:,:,:,c)=tmp;
end
NMv=reshape(double(vN),[],iN.ImageSize(4));
Rv =reshape(R,[],nR);
brain = all(isfinite(NMv),2) & all(isfinite(Rv),2);
fprintf('correlation mask: %d voxels\n\n', sum(brain));
save(fullfile(ROOT,'sc_tmp.mat'),'NMv','Rv','brain','-v7.3');
DOM={'CB',1:13;'VI-OT',14:19;'VI-OC',20:25;'PL',26:36;'SC-EH',37:39;'SC-ET',40:45; ...
     'SC-BG',46:54;'SM',55:68;'HC-IT',69:75;'HC-TP',76:80;'HC-FR',81:90; ...
     'TN-CE',91:93;'TN-DM',94:101;'TN-SA',102:105};
dom=@(i) DOM{find(cellfun(@(r)any(r==i),DOM(:,2)),1),1};
C=corr(NMv(brain,:), Rv(brain,:));      % 105 x nR

fprintf('===== Best NeuroMark match for each Smith RSN =====\n');
fprintf('(POSITIVE CONTROL: visual RSNs must hit VI-OT/VI-OC)\n');
fprintf('%-6s %28s %28s\n','RSN','best','2nd');
for c=1:size(C,2)
    [s,o]=sort(abs(C(:,c)),'descend');
    fprintf('%-6d %20s r=%+.2f %20s r=%+.2f\n', c, ...
        sprintf('ICN%d(%s)',o(1),dom(o(1))), C(o(1),c), ...
        sprintf('ICN%d(%s)',o(2),dom(o(2))), C(o(2),c));
end

fprintf('\n===== TN-DM (94-101) vs every Smith RSN =====\n');
fprintf('%-8s','ICN'); fprintf('%7d',1:size(C,2)); fprintf('\n');
for i=94:101
    fprintf('DMN%-5d',i); fprintf('%+7.2f',C(i,:)); fprintf('\n');
end
fprintf('\n===== TN-CE (91-93) vs every Smith RSN =====\n');
for i=91:93
    fprintf('ECN%-5d',i); fprintf('%+7.2f',C(i,:)); fprintf('\n');
end

fprintf('\n===== BENCHMARK vs paper (Table 2) =====\n');
fprintf('paper: IC1 DMN r=.69 | IC16 DMN r=.57 | IC13 ECN r=.62 | IC11 vDMN r=.48\n');
mx=max(abs(C(94:101,:)),[],2);
fprintf('our DMN ICNs, best |r| to ANY Smith RSN: %s\n', num2str(round(mx',2)));
fprintf('  -> max %.2f, median %.2f\n', max(mx), median(mx));
mx2=max(abs(C(91:93,:)),[],2);
fprintf('our ECN ICNs, best |r|: %s  (max %.2f)\n', num2str(round(mx2',2)), max(mx2));
