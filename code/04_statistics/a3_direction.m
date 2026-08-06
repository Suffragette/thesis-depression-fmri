clear; clc;
ROOT='/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
DMN=94:101; ECN=91:93;
mWk=triu(true(numel(DMN)),1);
g=[true(51,1);false(21,1)];

pipes = {
 '2.2 baseline', fullfile(ROOT,'output72','nmark72_postprocess_results'), 'nmark72_post_process_sub_%03d.mat';
 'v25',          fullfile(ROOT,'output72_v25','nmark72v25_postprocess_results'), 'nmark72v25_post_process_sub_%03d.mat';
 'Vpaper',       fullfile(ROOT,'output72_Vpaper','nmark72_Vpaper_postprocess_results'), 'nmark72_Vpaper_post_process_sub_%03d.mat';
 'V2 (no aCompCor)', fullfile(ROOT,'output72_V2','nmark72_V2_postprocess_results'), 'nmark72_V2_post_process_sub_%03d.mat';
};

fprintf('\n===== within-DMN & DMN-ECN: depr vs HC across pipelines =====\n');
fprintf('%-18s | within-DMN: depr    HC     dir      p    | DMN-ECN: depr    HC     dir      p\n','pipeline');
for k=1:size(pipes,1)
  folder=pipes{k,2}; fpat=pipes{k,3};
  wd=nan(72,1); de=nan(72,1);
  for s=1:72
    m=load(fullfile(folder,sprintf(fpat,s)));
    M=squeeze(m.fnc_corrs); M(isnan(M))=0;
    b1=M(DMN,DMN); wd(s)=mean(b1(mWk));
    b2=M(DMN,ECN); de(s)=mean(b2(:));
  end
  md=mean(wd(g)); mh=mean(wd(~g)); [~,pw]=ttest2(wd(g),wd(~g));
  if md>mh, dw='depr>HC'; else, dw='HC>depr'; end
  ed=mean(de(g)); eh=mean(de(~g)); [~,pe]=ttest2(de(g),de(~g));
  if ed>eh, dd='depr>HC'; else, dd='HC>depr'; end
  fprintf('%-18s | %+.4f %+.4f %-8s %.3f | %+.4f %+.4f %-8s %.3f\n', ...
    pipes{k,1}, md,mh,dw,pw, ed,eh,dd,pe);
end
fprintf('\nPaper claim: within-DMN decreased in depression (HC>depr).\n');
