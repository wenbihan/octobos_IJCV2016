function [ IMU ] = my_col2im(I1, n, TE, idx)
%Reconstruct the image from the patches
%   Put the patch back to the image with coresponding weights
% Not wrap-around
[rows,cols] = ind2sub(size(I1)-sqrt(n)+1,idx);              %patch index
[aa, bb] = size(I1);

IMout=zeros(aa,bb);
Weight=zeros(aa,bb);
bbb=sqrt(n);
for jj = 1:10000:size(TE,2)
    jumpSize = min(jj+10000-1,size(TE,2));
    ZZ= TE(:,jj:jumpSize);
    %+ (ones(size(TE,1),1) * br(jj:jumpSize));  %add back mean values of patches
    inx=(ZZ<0);ing= ZZ>255; ZZ(inx)=0;ZZ(ing)=255;   %restrict patches to range    
    for ii  = jj:jumpSize        
        col = cols(ii); row = rows(ii);
        block =reshape(ZZ(:,ii-jj+1),[bbb,bbb]);
        IMout(row:row+bbb-1,col:col+bbb-1)=IMout(row:row+bbb-1,col:col+bbb-1)+block;
        Weight(row:row+bbb-1,col:col+bbb-1)=Weight(row:row+bbb-1,col:col+bbb-1)+ones(bbb);
    end;
end
IMU=(IMout)./(Weight);
end

