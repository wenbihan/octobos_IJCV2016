function [transform, outputParam] = octobos(data, transform, param)
% =========================================================================
%                          OCTOBOS Learning Algorithm
% =========================================================================
% The OCTOBOS learning algorithm finds a structured sparsifying transform
% with block cosparsity (OCTOBOS), or a union of square transforms, for
% linear representation of signals. Given a set of signals, it searches for
% the best OCTOBOS that can sparsely represent each signal. Detailed
% discussion on the algorithm and possible applications can be found in

% (1) "Structured Overcomplete Sparsifying Transform Learning with
% Convergence Guarantees and Applications", written by B. Wen, S.
% Ravishankar, and Y Bresler, in the International Journal of Computer
% Vision, pp. 1-31, Oct. 2014. 

% (2) "Learning Overcomplete Sparsifying Transforms with Block Cosparsity",
% written by B. Wen, S. Ravishankar, and Y Bresler, in Proc. IEEE
% International Conference on Image Processing (ICIP), pp. 803 - 807, Oct.
% 2014.
% =========================================================================
% Inputs -
%       1. data : Image patch data - an nXN matrix that contins N signals,
%       each of dimension n. 
%
%       2. transform : initial OCTOBOS - an nXnXK matrix that contins K
%       square transforms, each of dimension nXn.
%
%       3. param: Structure that contains the parameters of the
%       OCTOBOS_imagedenoising algorithm. The various fields are as follows
%       -
%                   - numBlock: Number of blocks of the learned OCTOBOS
%                   (Example: 2)
%                   - n: Patch size as (Example: 81)
%                   - IDX: initial clustering index
%                   - NTE: Number of training data
%                   - l0: regularizer coefficient
%                   - roundLearning: number of rounds for transform learning
%                   - iter: number of OCTOBOS training iterations
%                   - T0: sparsity level
%
%                   - maxClusterSize: maximum allowed number of training
%                   data in each cluster.
%
% Outputs -
%       1. transform - learned OCTOBOS
%       3. outputParam: Structure that contains the parameters of the
%       algorithm output for analysis as follows
%       -
%                   - numBlock: number of blocks of the learned OCTOBOS
%                   - IDX:    Label of each patch
%                   - sizeCluster: size of each cluster in the iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numBlock = param.numBlock;
NTE = param.NTE;
l0 = param.l0;
iter = param.iter;
% STY0 = param.STY;
T0 = param.T0;
roundLearning = param.roundLearning;
IDX = param.IDX;
maxClusterSize = param.maxClusterSize;
n = param.n;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sizeCluster = zeros(iter, numBlock);                % cluster sizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1 : iter
    for k = 1 : numBlock
        c = find(IDX == k);
        sizeCluster(j, k) = size(c, 1);
        N4 = size(data(:, c),2);
        N3 = min(maxClusterSize,N4);
        de = randperm(N4);
        YH = data(:, c(de(:, 1: N3), :));        %training set for iteration
        STY =(ones(1,N3)) * T0;            %sparsity levels corresponding to training set
        l2 = l0 * norm(YH, 'fro') ^ 2;    % lambda_{k} Update
        %%%%%%%%% transform Learning %%%%%%%%% 
        [transform(:,:,k), ~] = transformLearning(YH, transform(:,:,k), l2, l2, STY, roundLearning);
    end
    error = zeros(numBlock, NTE);
    %%%%%%%%% clustering measure %%%%%%%%%
    for k = 1 : numBlock
        a1 = transform(:,:,k) * data;
        STY = ones(1,NTE) * T0;            %sparsity levels corresponding to training set
        a0 = sparseSTY(a1, STY);
        error(k, :) = sum((a1-a0).^2) + l0*(-log(abs(det(transform(:,:,k))))+norm(transform(:,:,k),'fro')^2).*sum((data).^2);
    end
    %%%%%%%%% clustering %%%%%%%%%
    [~, IDX] = min(error, [] ,1);
    IDX = IDX';
    [transform, numBlock] = eliminateEmptyCluster(transform, numBlock, IDX, n);      % check for empty cluster - eliminate
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputParam.numBlock = numBlock;
outputParam.IDX = IDX;
outputParam.sizeCluster = sizeCluster;
end