function [param] = OCTOBOS_imagereconstruction_param(param)
%Function for tuning paramters for OCTOBOS denoising

%Note that all input parameters need to be set prior to simulation. 
%This tuning function is just an example settings which we provide, for 
%generating the results in the "OCTOBOS paper". However, the user is
%advised to carefully modify this function, thus choose optimal values  
%for the parameters depending on the specific data or task at hand.

n = param.n;
K = param.numBlock;
T0 = round((0.17)*n);
%% initial OCTOBOS   -   transform
% Transform Initialization: DCT
D = kron(dctmtx(sqrt(n)),dctmtx(sqrt(n)));          
Dc = zeros(n,n,param.numBlock);
for i = 1:K
    Dc(:,:,i)=D;
end
%% number of iteration    -   iter
iter = 100;

param.T0 = T0;
param.transform = Dc;
param.iter = iter;
param.l0 = 0.0031;
param.roundLearning = 1;
param.maxClusterSize = 22400*1.43;
end

