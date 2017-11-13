function [Xr, transform, outputParam]= OCTOBOS_imagereconstruction(image, param)
%Function for sparse representation of the gray-scale image and
%reconstruction using OCTOBOS algorithm.
%
%Note that all input parameters need to be set prior to simulation. We
%provide some example settings using function
%OCTOBOS_imagereconstruction_param. However, the user is advised to
%carefully choose optimal values for the parameters depending on the
%specific data or task at hand.
%
%
% The OCTOBOS_imagereconstruction algorithm denoises an gray-scale image
% based on OCTOBOS learning. Detailed discussion on the algorithm can be
% found in
%
% (1) "Structured Overcomplete Sparsifying Transform Learning with
% Convergence Guarantees and Applications", written by B. Wen, S.
% Ravishankar, and Y Bresler, in the International Journal of Computer
% Vision (IJCV), pp. 1-31, Oct. 2014. 
%
% (2) "Learning Overcomplete Sparsifying Transforms with Block Cosparsity",
% written by B. Wen, S. Ravishankar, and Y Bresler, in Proc. IEEE
% International Conference on Image Processing (ICIP), pp. 803 - 807, Oct.
% 2014.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs -
%       1. image : Image data, a*b size gray-scale matrix.
%
%       2. param: Structure that contains the parameters of the
%       OCTOBOS_imagedenoising algorithm. The various fields are as follows
%       -
%                   - numBlock: Number of blocks of the learned OCTOBOS
%                   (Example: 2)
%                   - n: Patch size as (Example: 64)
%                   - stride: stride of overlapping patches
%                   - isKmeansInitialization: set to 1, if K-means initial
%                   clustering is used.
%
%                   (Optional) 
%
%                   - showStats: Set to 1, if the statistics (cost and
%                   sparseError) are output. The run time will be
%                   increased.
%
%                   - showNSE: Set to 1, if the NSE is output.
%                   The run time will be increased.
%
%
% Outputs -
%       1. Xr - Image reconstructed by OCTOBOS and sparse representation.
%       2. transform - learned OCTOBOS.
%       3. outputParam: Structure that contains the parameters of the
%       algorithm output for analysis as follows
%       -
%                   - IDX:    Label of each patch
%                   - time:   run time of the denoising algorithm
%                   - psnrOut: construction PSNR
%                   - T0:   sparsity level;
%
%                   (Optional)
%                   - sizeCluster: cluster size
%
%                   - sparseError: sparsifcation error
%
%                   - cost: objective function
%
%                   - NSE: normalized sparsification error

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%  Initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param = OCTOBOS_imagereconstruction_param(param);
n = param.n;                                % patch size / dimensionality
T0 = param.T0;                              % initial sparsity level
Xr = zeros(size(image));
transform = param.transform;                % initial transform
% iter = param.iter;                          % number of iterations in first pass denoising
% l0 = param.l0;                              % regularizer coefficient
% roundLearning = param.roundLearning;        % number of rounds for OCTOBOS learning
% maxClusterSize = param.maxClusterSize;      % maximum allowed cluster size
stride = param.stride;                      % stride of overlapping patches
numBlock = param.numBlock;                  % number of blocks of the learned OCTOBOS
isKmeansInitialization = param.isKmeansInitialization;
[data,idx] = my_im2col(image,[sqrt(n),sqrt(n)], stride);
mu = mean(data);
data = data - ones(param.n,1)*mu;
param.NTE = size(data,2);
NTE = param.NTE;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MAIN CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
if isfield(param, 'isKmeansInitialization') && isKmeansInitialization
    [IDX, ~] = kmeans(data',numBlock);              %   K-mean Initialization
else
    IDX = randi(numBlock,NTE,1);                   %   Random Initialization
end
param.IDX = IDX;
if isfield(param, 'showStats') && param.showStats
    param.showCost = true;
    param.showSparseError = true;
    param.showClusterSize = true;
end
[transform, outputParam] = octobos(data, transform, param);
numBlock = outputParam.numBlock;
IDX = outputParam.IDX;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Recovery Image  %%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1 : numBlock
    c = find(IDX == k);
    a1 = transform(:,:,k) * data(:, c);
    STY = ones(1, size(a1, 2)) * T0;
    a0 = sparseSTY(a1, STY);
    data(:, c) = pinv(transform(:,:,k)) * a0 + ones(n,1) * mu(:, c);
    IMU = viewCluster(Xr, n, c, data, idx);
    Xr = Xr + IMU;
end
outputParam.time = toc;
Xr(Xr<0)=0;
Xr(Xr>255)=255;
outputParam.psnrOut = PSNR(Xr - image);
param.IDX = IDX;
outputParam.T0 = T0;
if isfield(param, 'showNSE') && param.showNSE
    param.isImage = true;
    outputParam.nse = NSE(image, transform, param);
end
end