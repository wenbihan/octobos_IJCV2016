clear;
addpath('octobos_toolbox');
load('demo_data/noisy_Cameraman_sigma20.mat');

%%%%%%%%%%%%%%%% OCTOBOS image denoising demo %%%%%%%%%%%%%%%%%%%%%
param.n = 64;
param.stride = 1;
param.sig = sig;           
data.noisy = noisy;
data.oracle = oracle;
clear I7;
param.isKmeansInitialization = true;
param.numBlock = 4;
[denoised, transform, outputParam]= OCTOBOS_imagedenoising(data, param);
imshow(denoised, []);

