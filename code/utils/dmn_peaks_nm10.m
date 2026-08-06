clear; clc;
NII='/Users/hedylamarr/Documents/MATLAB/thesis_scripts/output_study2_nm10/rNeuromark_fMRI_1.0.nii';
info=niftiinfo(NII); vol=niftiread(info); A=info.Transform.T'; dim=info.ImageSize(1:3);
fprintf('%-7s %8s %8s %8s  %s\n','ICN','peakX','peakY','peakZ','likely');
for c=43:49
    img=double(vol(:,:,:,c));
    [~,idx]=max(img(:));
    [i1,i2,i3]=ind2sub(dim,idx);
    p=A*[i1-1;i2-1;i3-1;1];
    if p(2)>10, lab='ACC/mPFC (anterior)'; elseif p(2)<-40, lab='PCu/PCC (posterior)'; else, lab='mid'; end
    fprintf('DM%-4d %8.1f %8.1f %8.1f  %s\n', c, p(1),p(2),p(3), lab);
end
