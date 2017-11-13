function [blocks,idx] = my_im2col(I,blkSize,slidingDis)
idxMat = zeros(size(I)-blkSize+1);
idxMat([[1:slidingDis:end-1],end],[[1:slidingDis:end-1],end]) = 1;
idx = find(idxMat);
[rows,cols] = ind2sub(size(idxMat),idx);
blocks = zeros(prod(blkSize),length(idx));
for i = 1:length(idx)
    currBlock = I(rows(i):rows(i)+blkSize(1)-1,cols(i):cols(i)+blkSize(2)-1);
    blocks(:,i) = currBlock(:);
end
