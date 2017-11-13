function [Dc, K] = eliminateEmptyCluster(Dc, K, IDX, n)
% eliminate the cluster when the elements within is zero
K4 = K;
for jj = 1 : K4
    ll = length(find(IDX==jj));
    if(ll == 0)
        K=K-1;
        Dc(:,:,jj)=inf;
    end
end
inx=find(Dc==inf);
Dc(inx)=[];
Dc = reshape(Dc,[n n K]);
end

