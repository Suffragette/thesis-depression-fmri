clear; clc;
i=niftiinfo('/Users/hedylamarr/Downloads/rsn20.nii');
v=niftiread(i); A=i.Transform.T'; d=i.ImageSize(1:3);
[gx,gy,gz]=ndgrid(0:d(1)-1,0:d(2)-1,0:d(3)-1);
mni=A*[gx(:)';gy(:)';gz(:)';ones(1,numel(gx))];
fprintf('%-8s %8s %8s %8s   %s\n','RSN','X','Y','Z','position');
for c=[7 11 15]
    w=abs(double(reshape(v(:,:,:,c),[],1))); w(isnan(w))=0;
    q=quantile(w(w>0),0.90); m=w>=q;
    cen=(mni(1:3,m)*w(m))/sum(w(m));
    if cen(2)>10, p='ANTERIOR'; elseif cen(2)<-30, p='POSTERIOR'; else, p='mid'; end
    fprintf('RSN%-5d %8.1f %8.1f %8.1f   %s\n', c, cen(1),cen(2),cen(3), p);
end
