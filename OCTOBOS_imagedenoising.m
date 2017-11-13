function [Xr, transform, outputParam]= OCTOBOS_imagedenoising(data, param)
%Function for denoising the gray-scale image using OCTOBOS-based denoising
%algorithm.
%
%Note that all input parameters need to be set prior to simulation. We
%provide some example settings using function OCTOBOS_imagedenoise_param.
%However, the user is advised to carefully choose optimal values for the
%parameters depending on the specific data or task at hand.
%
%
% The OCTOBOS_imagedenoising algorithm denoises an gray-scale image based
% on OCTOBOS learning. Detailed discussion on the algorithm can be found in
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
%       1. data : Image data. The fields are as follows -
%                   - noisy: a*b size gray-scale matrix for denoising
%                   - oracle (optional): a*b size gray-scale matrix as
%                   ground-true, which is used to calculate PSNR
%
%       2. param: Structure that contains the parameters of the
%       OCTOBOS_imagedenoising algorithm. The various fields are as follows
%       -
%                   - numBlock: Number of blocks of the learned OCTOBOS
%                   (Example: 4)
%                   - sig: Standard deviation of the additive Gaussian
%                   noise (Example: 20)
%                   - n: Patch size as (Example: 64)
%                   - stride: stride of overlapping patches
%                   - isKmeansInitialization: Set to 1 if the clustering is
%                   initialized using K-means. Set to 0 if the clustering
%                   is initialized by random partition.
%
% Outputs -
%       1. Xr - Image reconstructed with OCTOBOS_imagedenoising algorithm.
%       2. transform - learned OCTOBOS.
%       2. outputParam: Structure that contains the parameters of the
%       algorithm output for analysis as follows
%       -
%                   - psnrXr: PSNR of Xr, if the oracle is provided
%                   - IDX:    Label of each patch
%                   - time:   run time of the denoising algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%  Initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param = OCTOBOS_imagedenoise_param(param);
n = param.n;                                % patch size / dimensionality
C1 = param.C1;                              % thresholding coefficient
sig2 = param.sig2;                          % multi-pass noise level estimates
la = param.la;                              % fidelity term coefficient
T0 = param.T0;                              % initial sparsity level
Xr = data.noisy;                            % noisy image
transform = param.transform;                % initial transform
iter = param.iter;                          % number of iterations in first pass denoising
iterMultipass = param.iterMultipass;        % number of iterations in multipass denoising
l0 = param.l0;                              % regularizer coefficient
roundLearning = param.roundLearning;        % number of rounds for OCTOBOS learning
maxClusterSize = param.maxClusterSize;      % maximum allowed cluster size
stride = param.stride;                      % stride of overlapping patches
numBlock = param.numBlock;                  % number of blocks of the learned OCTOBOS
isKmeansInitialization = param.isKmeansInitialization;
clear param;
stp = 1;                                    % sparsity increase stepsize
SP = 1:stp:round(9*T0);                     % maximum sparsity level allowed in algorithm is 9*T0 here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MAIN CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for pr = 1 : length(sig2)
    if(pr > 1)
        iter = iterMultipass;
    end
    sig = sig2(pr);
    threshold = C1 * sig * (sqrt(n));       %threshold in variable sparsity update
    % patch extraction and initialization
    [TE0,idx] = my_im2col(Xr,[sqrt(n),sqrt(n)],stride);
    NTE = size(TE0,2);
    mu = mean(TE0);
    TE0 = TE0 - ones(n,1)*mu;               %mean subtraction    
    if (pr==1)
        if isKmeansInitialization
            [IDX, ~] = kmeans(TE0',numBlock);              %   K-mean Initialization
        else
            IDX = randi(numBlock,NTE,1);                   %   Random Initialization
        end
        [transform, numBlock] = eliminateEmptyCluster(transform, numBlock, IDX, n);      % check for empty cluster - eliminate
    end
    STY0 = ones(1, NTE).*T0;                            % Initial Sparsity Vector
    l2 = zeros(numBlock, 1);                            % lambda_{k}
    error = zeros(numBlock, NTE);                       % ||Wy-Hs(Wy)||
    sizeCluster = zeros(iter, numBlock);                % cluster sizes
    Xr = zeros(size(Xr));                               % Total recovery
    % OCTOBOS learning iteration
    for j =1 : iter
        for k = 1 : numBlock
            c=find(IDX == k);
            sizeCluster(j, k) = size(c, 1);
            N4 = size(TE0(:,c),2);
            N3 = min(maxClusterSize,N4);
            de = randperm(N4);
            YH = TE0(:, c(de(:, 1: N3), :));        %training set for iteration
            STY = STY0(1, c);                       %sparsity levels corresponding to current cluster
            STYYH = STY(:,de(1:N3));
            l2(k, 1) = l0 * norm(YH, 'fro') ^ 2;    % lambda_{k} Update
            % iterates more initially
            if j < iter/3
                currentRoundLearning = roundLearning*2;    %roundLearning is maximum number of learning iterations
            else
                currentRoundLearning = roundLearning;
            end                                    
            [transform(:,:,k), ~] = transformLearning(YH, transform(:,:,k), l2(k,1), l2(k,1), STYYH, currentRoundLearning);
            [STY0(1,c), reconstruction] = sparsityUpdate(TE0(:,c), transform(:,:,k), la, threshold, SP);        % Sparsity Update for YH
            % last iteration, add back the mean
            if (j==iter)
                reconstruction = reconstruction + ones(n,1)*mu(:, c);
                reconstruction(reconstruction<0)=0;
                reconstruction(reconstruction>255)=255;
                TE0(:,c)=reconstruction;
            end
            % calculate clustering measure via sparse coding
            for jj = 1:60000:size(TE0,2)
                jumpSize = min(jj+60000-1,size(TE0,2));
                ZZ = TE0(:,jj:jumpSize);
                a1 = transform(:,:,k)*ZZ;
                a0 = sparseSTY(a1, STY0(:,jj:jumpSize));
                error(k,jj:jumpSize) = sum((a1-a0).^2);
                error(k,jj:jumpSize) = error(k,jj:jumpSize) + l0 *(-log(abs(det(transform(:,:,k))))+norm(transform(:,:,k),'fro')^2).*sum((ZZ).^2);
            end
        end
        % clustering
        [~, IDX]=min(error, [], 1);
        IDX = IDX';
        [transform, numBlock] = eliminateEmptyCluster(transform, numBlock, IDX, n);      % check for empty cluster - eliminate     
    end
%  Patches Recovery
    for k = 1:numBlock
        c=find(IDX==k);
        IMU = viewCluster(Xr,n,c,TE0,idx);
        Xr = Xr + IMU;
    end
    Xr(Xr < 0) = 0;
    Xr(Xr > 255) = 255;
    if isfield(data, 'oracle')
        outputParam.psnrXr = PSNR(Xr-data.oracle);
    end
end
outputParam.time = toc;
outputParam.IDX = IDX;
end