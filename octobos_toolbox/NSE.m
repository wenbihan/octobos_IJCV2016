function [SE] = NSE(data, transform, param)
n = param.n;
s = param.T0;
K = param.numBlock;
if K > 1
    SE1 = 0;
    SE2 = 0;
end
IDX = param.IDX;
if param.isImage
    overlap = param.stride;
    [data, ~] = my_im2col(data,[sqrt(n),sqrt(n)],overlap);   %extract patches
    data = data - ones(n,1) * mean(data);
end
    NTE = size(data, 2);

if K == 1
    a1 = transform * data;
    STY =(ones(1, NTE)) * s;
    a0 = sparseSTY(a1, STY);
    SE = norm(a1 - a0, 'fro')^2 / norm(a1, 'fro')^2;
else
    for k = 1 : K
        a1 = transform(:, :, k) * data(:, IDX == k);
        STY =(ones(1, size(a1, 2))) * s;
        a0 = sparseSTY(a1, STY);
        SE1 = SE1 + norm(a1 - a0, 'fro')^2;
        SE2 = SE2 + norm(a1, 'fro')^2;
    end
    SE = SE1 / SE2;
end