function [Xr, outputParam] = OCTO_imagereconstruction(image, transform, param)
%Function for sparse representation of the gray-scale image and
%reconstruction using given (fixed) overcomplete sparsifying transform
%(OCTO) with block cosparsity.
%
% The OCTO_imagereconstruction algorithm denoises an gray-scale image based
% on transform with block cosparsity framework without learning. Detailed
% discussion on the algorithm can be found in
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
%       2. transform: Given fixed overcomplete transform
%
%       3. param: Structure that contains the parameters of the
%       OCTOBOS_imagedenoising algorithm. The various fields are as follows
%       -
%                   - n: Patch size as (Example: 64)
%                   - stride: stride of overlapping patches
%                   - IDX:
%                   - T0:
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
%       1. Xc - Images segmented with OCTOBOS_texturesegmentation algorithm
%       2. transform - learned OCTOBOS.
%       3. outputParam: Structure that contains the parameters of the
%       algorithm output for analysis as follows
%       -
%                   - psnrOut: construction PSNR
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

n = param.n;
stride = param.stride;
[data,idx] = my_im2col(image,[sqrt(n),sqrt(n)], stride);
mu = mean(data);
data = data - ones(param.n,1)*mu;
IDX = param.IDX;
numBlock = size(transform, 3);
Xr = zeros(size(image));
T0 = param.T0;
for k = 1 : numBlock
    c = find(IDX == k);
    a1 = transform(:,:,k) * data(:, c);
    STY = ones(1, size(a1, 2)) * T0;
    a0 = sparseSTY(a1, STY);
    data(:, c) = pinv(transform(:,:,k)) * a0 + ones(n,1) * mu(:, c);
    IMU = viewCluster(Xr, n, c, data, idx);
    Xr = Xr + IMU;
end
outputParam.psnrOut = PSNR(Xr - image);
if isfield(param, 'showNSE') && param.showNSE
    param.isImage = true;
    outputParam.nse = NSE(image, transform, param);
end
end

