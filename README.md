The following codes are used to process the statistical framework using searchlight technique

1. run the "SearchRoiLabel.m" in order to find the coordinate of each voxel in ROI region.

2. run the "CreateFeatures.m" in order to create the .mat files of all the subjects. The contents of 
the mat files include a M✖N matrix， M is the number of searchlight, N is the number of features

The steps above correspond to Figure 1a. Don't forget to reduce the extracted features dimensionally, multiple dimension-reduction methods can be used as needed.

3. run the "cluster_SVM_10fold.m", features of each voxel was used 10-fold SVM to output brain regions identified with high accuracy to classify DD and ODD group.

4. run the "cluster_cognition_pred3.m", GLM was used to predict multi-domain cognitive function scores based on the features of each voxel. Correlations between predicted and observed scores were calculated to which cognitive domain these voxels are most represented. 
