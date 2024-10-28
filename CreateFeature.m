% 

%load('/brain/zhang_group/Desktop/LiYuMeng/Digital Divide/Result/Roi_Label_total.mat')
curDir = pwd;
dirData = fullfile(curDir,'Part7');
dirSave = fullfile(curDir,'IndividualMNI');

nameAnalysis = 'MVPA_CueValue_pmodFeedbackRT_perRun_MNIs5wa_perPhase';
dirAnat = dir(fullfile(dirData,'*.nii'));
% GMV_single_total=[];
% GMV_sum_total=[];
for iS =1:length(dirAnat)
    nameGM=dirAnat(iS).name;
    newnameGM = extractBefore(nameGM,[".nii"]);
    nameGMResampled = fullfile(dirData,nameGM);%fullfile(dirAnat,['frwc1' scanP.subjID{iS} '_anat0001.img']);
    %nameGMResampled = fullfile(curDir,'frc1T1_Original.img');
    infoHdr = spm_vol(nameGMResampled);
    threshold = 0;
    r = 2; % searchlight radus (e.g., r = 3 voxels)
    V = 33;
    saveName = fullfile(dirSave,[newnameGM '.mat']);
    dim=[121 145 121];
%     col=colt;
%     row=rowt;
%     z=zt;
   % ClusterOneScanVoxelFile(nameGMResampled, infoHdr.dim, threshold, r, V);
   F=spm_vol(nameGMResampled);
   idx=spm_read_vols(F);
   
   tIdx_sum=[];
   h = waitbar(0, 'Calculating...');  % 创建进度条
   totalIterations = length(col); % 计算总迭代次数
   currentIteration = 0;  % 当前迭代次数
   for n = 1:length(col)
       i=row(n);
       j=col(n);
       k=z(n);
        % 更新迭代次数
       currentIteration = currentIteration + 1;   
       % 更新进度条
       waitbar(currentIteration / totalIterations, h, sprintf('Calculating... %d%%', round(currentIteration / totalIterations * 100)));
       tIdx = [];
       for i0 = -r : r
           for j0 = -r : r
               for k0 = -r : r
                   if (i + i0 >= 1 && i + i0 <= dim(1) && j + j0 >= 1 && j + j0 <= dim(2) && k + k0 >= 1 && k + k0 <= dim(3) && i0 * i0 + j0 * j0 + k0 * k0 <= r * r)
                       if (idx(i + i0, j + j0, k + k0) > threshold)
                           tIdx(end + 1) = idx(i + i0, j + j0, k + k0);
                           if (length(tIdx)==V)
                               tIdx_total=[length(tIdx) i j k tIdx sum(tIdx)];
                               tIdx_sum = cat(1, tIdx_sum,tIdx_total);
                           end
                       end
                   end
               end
           end
       end
   end
 
 
   close(h);  % 关闭进度条
   
   assignin('base',newnameGM,tIdx_sum);
   save(saveName,newnameGM);

%      GMV_single=tIdx_sum(:,5:37);
%      GMV_single_total=cat(3,GMV_single_total,GMV_single);
%      GMV_sum=tIdx_sum(:,38);
%      GMV_sum_total=cat(2,GMV_sum_total,GMV_sum);

end
