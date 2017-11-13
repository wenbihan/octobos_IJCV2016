function [Xc, transform, outputParam] = OCTOBOS_texturesegmentation(image, param)
%Function for denoising the gray-scale image using OCTOBOS-based denoising
%algorithm.
%
%Note that all input parameters need to be set prior to simulation. We
%provide example settings using function OCTOBOS_texturesegmentation_param.
%However, the user is advised to carefully choose optimal values for the
%parameters depending on the specific data or task at hand.
%
%
% The OCTOBOS_texturesegmentation algorithm segments a gray-scale image
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
%                   - n: Patch size as (Example: 81)
%                   - stride: stride of overlapping patches
%                   - isKmeansInitialization: Set to 1 if the clustering is
%                   initialized using K-means. Set to 0 if the clustering
%                   is initialized by random partition.
%
% Outputs -
%       1. Xc - Images segmented with OCTOBOS_texturesegmentation algorithm
%       2. transform - learned OCTOBOS.
%       3. outputParam: Structure that contains the parameters of the
%       algorithm output for analysis as follows
%       -
%                   - clusterMap: map of the pixel labels
%                   - IDX:    Label of each patch
%                   - time:   run time of the denoising algorithm
%                   - sizeCluster: size of each cluster in the iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%  Initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param = OCTOBOS_texturesegmentation_param(param);
n = param.n;                                % patch size / dimensionality
transform = param.transform;                % initial transform
numBlock = param.numBlock;                  % number of blocks of the learned OCTOBOS
stride = param.stride;                      % stride of overlapping patches
iter = param.iter;                          % number of OCTOBOS training iterations
isKmeansInitialization = param.isKmeansInitialization;
sizeCluster = zeros(iter, numBlock);                % cluster sizes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MAIN CODE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% patch extraction and initialization
[TE0,idx] = my_im2col(image,[sqrt(n),sqrt(n)],stride);
[rows,cols] = ind2sub(size(image) - sqrt(n) + 1, idx);              %patch index
NTE = size(TE0, 2);
param.NTE = NTE;
mu = mean(TE0);
TE0 = TE0 - ones(n,1)*mu;               %mean subtraction
if isKmeansInitialization
    [IDX, ~] = kmeans(TE0',numBlock);              %   K-mean Initialization
else
    IDX = randi(numBlock,NTE,1);                   %   Random Initialization
end
[transform, numBlock] = eliminateEmptyCluster(transform, numBlock, IDX, n);      % check for empty cluster - eliminate
param.isClusterSizeLimit = true;
param.IDX = IDX;
param.numBlock = numBlock;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  OCTOBOS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[transform, outputParam] = octobos(TE0, transform, param);
outputParam.time = toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Visualization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IDX = outputParam.IDX;
numBlock = outputParam.numBlock;
c = cell(numBlock, 1);                              % index of patches in each cluster
for k = 1 : numBlock
    c{k,1} = find(IDX == k);  
end
[Xc, clusterMap] = exactClusterK(image, rows, cols, c, numBlock, n, NTE);     % exact segmentation by voting
% [ Xc, ClusterMap] = simpleCluster(I7, X(:,numiter));                % approximate segmentation by majority intensity
outputParam.clusterMap = clusterMap;
outputParam.IDX = IDX;
outputParam.sizeCluster = sizeCluster;
end

