function [ Xc, ClusterMap] = exactClusterK(X, rows, cols, c, K, n, N4)
%cluster according to the recovered intensity
%   Xr is the recovered image
%   X is the clustered image by directly patch returning
[aa,bb]=size(X);
bbb = sqrt(n);
ClusterMap1=zeros(aa,bb, K);
ClusterMap = zeros(aa,bb);
% Weight = zeros(aa,bb);
Xc = cell(K,1);
for ii = 1:K
    Xc{ii,1}=ClusterMap;
end

for k = 1:K
    ck = c{k,1};
    for ii =1:N4
        col = cols(ii); row = rows(ii);
        if(~isempty(find(ck==ii,1)))
            ClusterMap1(row:row+bbb-1,col:col+bbb-1, k) = ClusterMap1(row:row+bbb-1,col:col+bbb-1, k) + ones(bbb);
        end
%         if (k == 1)
%         Weight(row:row+bbb-1,col:col+bbb-1) =Weight(row:row+bbb-1,col:col+bbb-1) + ones(bbb);
%         end
        %     Xc{ii,1}(row:row+bbb-1,col:col+bbb-1) = X(row:row+bbb-1,col:col+bbb-1);
    end
end
% for m = 1:aa
%     for n = 1:bb
%         [t, ClusterMap(m,n)] = max(ClusterMap1(m,n,:));
%     end
% end
[t, ClusterMap] = max(reshape(ClusterMap1,[aa*bb,K])');
ClusterMap = reshape(ClusterMap,[aa,bb]);
    
for k = 1:K
    Xc{k,1}(ClusterMap == k) = X(ClusterMap == k);
end

end

