clear all;
addpath('octobos_toolbox');     
load('demo_data/twoTextureExample.mat');

%%%%%%%%%%%%%%%% OCTOBOS image segmentation demo %%%%%%%%%%%%%%%%%%%%%

param.stride = 1;
param.n = 81;
param.numBlock = 2;
param.isKmeansInitialization = true;

% two texture segmentation demo
[Xc, transform, outputParam] = OCTOBOS_texturesegmentation(image, param);
% visualization
colorCode = [0, 200, 0];                        % green for demo. Pick your favorate color
% show class 1, for demo
classNumber = 1;
segment = clusterVisual(image, outputParam.clusterMap, classNumber, colorCode);
figure; imshow(segment);






