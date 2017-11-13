clear;
addpath('octobos_toolbox');

%%%%%%%%%%%%%%%% OCTOBOS image reconstruction demo %%%%%%%%%%%%%%%%%%%%%
load('demo_data/Barb.mat');
param.n = 64; 
param.numBlock = 2; 
param.stride = 8;
param.isKmeansInitialization = 0;
param.showStats = 1;
param.showNSE = 1;
param.showSwap = 1;
[Xr, transform, outputParam] = OCTOBOS_imagereconstruction(image, param);
display(outputParam);                       % PSNR and NSE
% condition number
condTransform = zeros(param.numBlock, 1);
for k = 1 : param.numBlock
    condTransform(k, 1) = cond(transform(:, :, k));
end
% swapping experiment
transformTemp = transform(:, :, 1);
transform(:, :, 1) = transform(:, :, 2);
transform(:, :, 2) = transformTemp;
clear transformTemp;
param.IDX = outputParam.IDX;
param.T0 = outputParam.T0;
[Xr_swap, outputParam_swap] = OCTO_imagereconstruction(image, transform, param);
display(outputParam_swap);