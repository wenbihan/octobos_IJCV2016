clear all;
close all;
addpath('octobos_toolbox');
load('demo_data/Barb.mat');

%%%%%%%%%%%%%%%% OCTOBOS convergence demo %%%%%%%%%%%%%%%%%%%%%
param.n = 64;
param.T0 = 11;
patchSize = sqrt(param.n);
param.iter = 600;
param.roundLearning = 1;
param.numBlock = 2;
param.l0 = 0.0031;
[data,idx] = my_im2col(I7,[sqrt(param.n),sqrt(param.n)],patchSize);
param.NTE = size(data,2);
mu = mean(data);
data = data - ones(param.n,1)*mu;
D0 = kron(dctmtx(sqrt(param.n)),dctmtx(sqrt(param.n)));
transform = zeros(param.n, param.n, param.numBlock);
for k = 1: param.numBlock
    transform(:, :, k) = D0;
end
param.maxClusterSize = 350*64;
% select the initialization
K = param.numBlock;
N4 = param.NTE;
IDX = randi(K, N4, 1);                                % Random
% [IDX, ~] = kmeans(TE0',K);                          % Kmeans
% IDX = ones(N4,1); IDX(1:N4/2,1) = 2;                % Equally Partition
% IDX = ones(N4,1); param.numBlock = 1;               % Single Block 
%%%%%%%%%%%%%%% OCTOBOS Learning %%%%%%%%%%%%%%%%%%%%%%%%%%%
param.IDX = IDX;
param.showCost = true;
param.showSparseError = true;
param.showClusterSize = true;
[transform, outputParam] = octobos(data, transform, param);
%%%%%%%%%%%%%%% Plot convergence curve %%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; 
semilogx(1:param.iter, outputParam.cost, 'MarkerSize',10,'LineWidth',3.2);
