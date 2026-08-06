%% STUDY 2: connection-level changes, per subject. NO interpretation.
%  Part 1: for each subject, the connections that changed most
%  Part 2: do any connections change consistently across subjects?
%  Part 3: for consistent connections, breakdown by treatment group
clear; clc;
D  = '/Users/hedylamarr/Documents/MATLAB/thesis_scripts';
PP = fullfile(D,'output_study2','nmark_s2_postprocess_results');

dom = strings(105,1);
dom(1:13)="CB"; dom(14:19)="VI-OT"; dom(20:25)="VI-OC"; dom(26:36)="PL";
dom(37:39)="SC-EH"; dom(40:45)="SC-ET"; dom(46:54)="SC-BG"; dom(55:68)="SM";
dom(69:75)="HC-IT"; dom(76:80)="HC-TP"; dom(81:90)="HC-FR";
dom(91:93)="ECN"; dom(94:101)="DMN"; dom(102:105)="SAL";
cname = @(i) sprintf('%s%d', dom(i), i);

cl = readtable(fullfile(D,'clinical_study2.tsv'),'FileType','text','Delimiter','\t','TreatAsMissing',{'n/a'});
g  = string(cl.group);
gs = strings(29,1); gs(g=="depr_no_treatment")="NT"; gs(g=="depr_cbt")="CBT"; gs(g=="depr_nfb")="NFB";
dB = cl.(matlab.lang.makeValidName('BDI_ses-post')) - cl.(matlab.lang.makeValidName('BDI_ses-pre'));

%% load and difference
F = nan(105,105,58);
for k=1:58
    s=load(fullfile(PP,sprintf('nmark_s2_post_process_sub_%03d.mat',k)));
    m=squeeze(s.fnc_corrs); m(isnan(m))=0; F(:,:,k)=m;
end
DEL = F(:,:,2:2:end) - F(:,:,1:2:end);          % 105x105x29, post - pre
msk = triu(true(105),1);
[I,J] = find(msk);
nP = numel(I);
V = nan(nP,29);
for i=1:29, a=DEL(:,:,i); V(:,i)=a(msk); end

fprintf('%d connections x 29 subjects\n', nP);
fprintf('SD of change within a subject: %.3f (median across connections)\n\n', median(std(V,0,2)));

%% ---------- PART 1: per subject, biggest changes ----------
fprintf('==========================================================================\n');
fprintf('PART 1. THE 5 LARGEST CONNECTIVITY CHANGES, SUBJECT BY SUBJECT\n');
fprintf('  value = post - pre correlation. + = increased, - = decreased\n');
fprintf('==========================================================================\n');
for i = 1:29
    [~,ord] = sort(abs(V(:,i)),'descend');
    fprintf('\nsub-%02d  [%s]  dBDI=%s\n', i, gs(i), fmt(dB(i)));
    for k = 1:5
        p = ord(k);
        fprintf('   %-14s %-14s  pre %+0.3f -> post %+0.3f   change %+0.3f\n', ...
            cname(I(p)), cname(J(p)), F(I(p),J(p),2*i-1), F(I(p),J(p),2*i), V(p,i));
    end
end

%% ---------- PART 2: consistency across subjects ----------
fprintf('\n\n==========================================================================\n');
fprintf('PART 2. DO ANY CONNECTIONS CHANGE IN THE SAME DIRECTION IN MANY SUBJECTS?\n');
fprintf('==========================================================================\n');
nPos = sum(V>0,2); nNeg = sum(V<0,2);
agree = max(nPos,nNeg);                       % how many of 29 agree in direction
fprintf('Connections where >=%d/29 subjects change the SAME direction:\n', 22);
for thr = [22 24 26 29]
    nHit = sum(agree>=thr);
    % expected by chance (binomial, p=0.5, two-sided)
    pc = 2*(1-binocdf(thr-1,29,0.5));
    fprintf('   >=%2d/29 agree : %4d connections   (expected by chance: %.1f)\n', ...
            thr, nHit, nP*pc);
end

fprintf('\nTop 15 most consistent connections:\n');
fprintf('%-14s %-14s %8s %10s %12s\n','network A','network B','agree','mean chg','direction');
[~,ord] = sort(agree,'descend');
for k = 1:15
    p = ord(k);
    dir = 'increase'; if nNeg(p)>nPos(p), dir='decrease'; end
    fprintf('%-14s %-14s %5d/29 %+10.4f %12s\n', cname(I(p)), cname(J(p)), agree(p), mean(V(p,:)), dir);
end

%% ---------- PART 3: treatment breakdown for the top connection ----------
fprintf('\n\n==========================================================================\n');
fprintf('PART 3. FOR THE 5 MOST CONSISTENT CONNECTIONS: WHO CHANGED, AND HOW\n');
fprintf('==========================================================================\n');
for k = 1:5
    p = ord(k);
    dirv = sign(mean(V(p,:)));
    fprintf('\n--- %s <-> %s   (%d/29 agree, mean %+0.4f) ---\n', ...
            cname(I(p)), cname(J(p)), agree(p), mean(V(p,:)));
    fprintf('%-8s %-5s %10s %8s\n','subj','grp','change','dBDI');
    for i = 1:29
        mark = ' '; if sign(V(p,i))==dirv, mark='*'; end
        fprintf('sub-%02d   %-5s %+10.4f %8s %s\n', i, gs(i), V(p,i), fmt(dB(i)), mark);
    end
    for grp = ["NT","CBT","NFB"]
        idx = find(gs==grp);
        n = sum(sign(V(p,idx))==dirv);
        fprintf('   %-4s: %d/%d in the majority direction\n', grp, n, numel(idx));
    end
end

fprintf('\n\nNOTE: with %d connections tested, some will look consistent by chance.\n', nP);
fprintf('The "expected by chance" column in Part 2 is the reference point.\n');

function s = fmt(v)
    if isnan(v), s='.'; else, s=sprintf('%+.0f',v); end
end
