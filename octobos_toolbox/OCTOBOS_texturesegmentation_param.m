function [param] = OCTOBOS_texturesegmentation_param(param)
%Function for tuning paramters for OCTOBOS denoising

%Note that all input parameters need to be set prior to simulation. 
%This tuning function is just an example settings which we provide, for 
%generating the results in the "OCTOBOS paper". However, the user is
%advised to carefully modify this function, thus choose optimal values  
%for the parameters depending on the specific data or task at hand.

n = param.n;
K = param.numBlock;
%% initial sparsity     -   T0
T0 = round((0.12)*n);
%% initial OCTOBOS   -   transform
% Transform Initialization: DCT
D = kron(dctmtx(sqrt(n)),dctmtx(sqrt(n)));          
Dc = zeros(n,n,param.numBlock);
for i = 1:K
    Dc(:,:,i)=D;
end
%% number of iteration    -   iter
if K <= 2
    iter = 20;
    maxClusterSize = 350*64*20;
elseif K == 3
    iter = 70;
    maxClusterSize = 80000;
else
    iter = 100;
    maxClusterSize = 80000;    
end

param.T0 = T0;
param.transform = Dc;
param.iter = iter;
param.l0 = 3.1e-3;
param.roundLearning = 1;
param.maxClusterSize = maxClusterSize;
end

