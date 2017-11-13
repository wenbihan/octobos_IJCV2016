function [ IMU ] = viewCluster(I1, n, c, TE, idx)
%Visualize the clustered image
%   Put the patch back to the image with coresponding weights
% Not wrap-around
[rows,cols] = ind2sub(size(I1)-sqrt(n)+1,idx);              %patch index
[aa, bb]=size(I1);

IMout=zeros(aa,bb);Weight=zeros(aa,bb);
bbb=sqrt(n);
% to prevent data exceeds
c = [c;-1];
pter = 1;
ider = c(pter,1);
for jj = 1:10000:size(TE,2)
    jumpSize = min(jj+10000-1,size(TE,2));
    ZZ= TE(:,jj:jumpSize);
    %+ (ones(size(TE,1),1) * br(jj:jumpSize));  %add back mean values of patches
    inx=(ZZ<0);ing= ZZ>255; ZZ(inx)=0;ZZ(ing)=255;   %restrict patches to range
    
    for ii  = jj:jumpSize        
        col = cols(ii); row = rows(ii);
        block =reshape(ZZ(:,ii-jj+1),[bbb,bbb]);
        if(ider == ii)
        IMout(row:row+bbb-1,col:col+bbb-1)=IMout(row:row+bbb-1,col:col+bbb-1)+block;
        pter = pter+1;
        ider = c(pter,1);
        end
        Weight(row:row+bbb-1,col:col+bbb-1)=Weight(row:row+bbb-1,col:col+bbb-1)+ones(bbb);
    end;
end

IMU=(IMout)./(Weight);   %IMU is denoised image

end

