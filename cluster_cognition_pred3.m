clear;
% DD_PGM.mat = 3-D matrix(NxMxS): 
% N=DD group participant number; M=feature number of every voxel; S = voxel number in your ROI
% the same as ODD_PGM.mat
load('DD_PGM.mat');
load('ODD_PGM.mat');
% cognition.mat = NxM matrix of participants' cognitive scores; 
% N = participant number of two groups; M = multi-domain of cognition
load('cognition.mat');

R_glmnet_total_sum=[];
P_glmnet_total_sum=[];

h = waitbar(0, 'Calculating...');

fprintf('Start：');
for j =1:size(cognition,2)
    cog_train_single=cog_train(:,j);
    cog_test_single=cog_test(:,j);
    
    R_glmnet_total=[];
    P_glmnet_total=[];
    for i=1:size(GMV_total,3)
    % Perform ten-fold cross-validation by looping through folds
    num_folds = 10;
    indices = crossvalind('Kfold', size(GMV_total, 3), num_folds);

        for fold = 1:num_folds
            X_train_fold = X_train(:,:,indices ~= fold);
            cog_train_fold = cog_train(:, :, indices ~= fold);

            X_test_fold = X_train(:, :, indices == fold);
            cog_test_fold = cog_train(:, :, indices == fold);

            [R_glmnet_single_fold, P_glmnet_single_fold] = deal([]);

            for i = 1:size(X_test_fold, 3)
                X_train_single = X_train_fold(:, :, i);
                cog_train_single = cog_train_fold(:, i);
        
                [fit, dev, stats] = glmfit(X_train_single, cog_train_single, 'normal');
                B = fit(2:34, 1);
        
                y_pred = X_test_fold(:,:,i) * B;
                [R_glmnet, P_glmnet] = corr(y_pred, cog_test_single);
                R_glmnet_single_fold = cat(1, R_glmnet_single_fold, R_glmnet);
                P_glmnet_single_fold = cat(1, P_glmnet_single_fold, P_glmnet);
            end

            R_glmnet_total = cat(2, R_glmnet_total, R_glmnet_single_fold);
            P_glmnet_total = cat(2, P_glmnet_total, P_glmnet_single_fold);
        end
    end
end
close(h);

%FDR correction
for k=1:size(cognition,2)
    rname=['Cognition_FDR' num2str(k)];
    %Memory/VisualSpatial/ProcessingSpeed/ExecutiveFunction/WorkingMemory/MentalHealth/VFT
    P_single_cognition=P_glmnet_total_sum(:,k);
    P_fdr=mafdr(P_single_cognition,'BHFDR',true);
    P_fdr_label=find(P_fdr<0.01);
    P_FDR=P_fdr(P_fdr_label);
    R_FDR=R_glmnet_total_sum(P_fdr_label);
    coor_FDR=[];
    for kk=1:length(P_fdr_label)
        coor_FDR_single=coordinate(:,:,kk);
        coor_FDR=cat(1,coor_FDR,coor_FDR_single);
    end
    FDR_total=cat(2,P_FDR,R_FDR,coor_FDR);
    assignin('base',rname,FDR_total);
end

%nifti image output
for m=1:size(cognition,2)
    fileName=fullfile(pwd,'cluster1_mask.nii');
    F=spm_vol(fileName);
    idx=zeros(121,145,121);
    cname=['Cognition_FDR' num2str(m)];
    zhongzhuan=evalin('base',cname);
    for n=1:length(zhongzhuan)
        coor=zhongzhuan(:,3:5);
        coor1=coor(n,1);
        coor2=coor(n,2);
        coor3=coor(n,3);
        idx(coor1,coor2,coor3)=zhongzhuan(n,2);
    end
    F.fname=[cname '.nii'];
    spm_write_vol(F,idx);
end



