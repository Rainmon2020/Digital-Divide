clear;
% DD_PGM.mat = 3-D matrix(NxMxS): 
% N=DD group participant number; M=feature number of every voxel; S = voxel number in your ROI
% the same as ODD_PGM.mat
load('DD_PGM.mat');
load('ODD_PGM.mat');

GMV_total=cat(1,ODD_PGM,DD_PGM);
coordinate=GMV_total(1,2:4,:);

R_value_sum=[];
coordi_FDR_total=[];


fprintf('Start：');
h = waitbar(0, 'Calculating...');

accuracy_total=[];
    
for i=1:size(GMV_total,3)
    num_folds = 10;
    indices = crossvalind('Kfold', size(X_train, 3), num_folds);
    accuracy_total = [];

    for fold = 1:num_folds
        X_train_fold = X_train(:, :, indices ~= fold);
        Y_train_fold = Y_train(indices ~= fold);

        X_test_fold = X_train(:, :, indices == fold);
        Y_test_fold = Y_train(indices == fold);

        [YPred_fold, accuracy_fold] = deal([]);

        for i = 1:numel(Y_test_fold)
            SVMModel = fitcsvm(X_train_fold(:, :, i), Y_train_fold);
            YPred = predict(SVMModel, X_test_fold(:, :, i));

            count = sum(YPred == Y_test_fold);
            accuracy = count / numel(Y_test_fold);
            accuracy_fold = cat(1, accuracy_fold, accuracy);
        end

        accuracy_total = cat(1, accuracy_total, accuracy_fold);
    end
    waitbar(i/size(GMV_total,3), h);
end
close(h);
accuracy_label=find(accuracy_total>0.6);
accuracy_coordi=coordinate(1,:,accuracy_label);
accuracy_value=accuracy_total(accuracy_label);


fileName=fullfile(pwd,'cluster1_mask.nii');
F=spm_vol(fileName);
idx=zeros(121,145,121);

for k=1:length(accuracy_value)
    coor=accuracy_coordi(1,:,k);
    coor1=coor(1,1);
    coor2=coor(1,2);
    coor3=coor(1,3);
    idx(coor1,coor2,coor3)=accuracy_value(k);
end

F.fname='SVM_accuracy_total.nii';
%F.dt=[512 0];
spm_write_vol(F,idx);



