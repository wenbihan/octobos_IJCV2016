function [X] = sparseSTY( X1, STY )
%SPARSESTY Summary of this function goes here
%   Detailed explanation goes here
[K, N] = size(X1);
ix=find(STY>0); 
a0=X1(:,ix); 
STY=STY(:,ix); 
N=size(a0,2);
ez=K*(0:(N-1));
STY = STY + ez;
[s]=sort(abs(a0),'descend');
a1 = a0.*(bsxfun(@ge,abs(a0),s(STY)));
X = zeros(size(X1));
X(:,ix) = a1;
end

