function [Td] = displayTwoTransform(DA, DB, n, betweenBlockMargin, betweenTransformMargin)
bbb = sqrt(n);
t = max(max(max(DA)), max(max(DB)));
Td = t * ones((n + (bbb - 1) * betweenBlockMargin)*2 + betweenTransformMargin,...
    (n + (bbb - 1) * betweenBlockMargin));
jy=2;
cc=1;
for i=1 : bbb + jy : ((bbb - 1) * (bbb + jy) ) + 1
    for j=1:bbb + jy:((bbb - 1) * (bbb + jy))+1
        Td(i:i+bbb-1,j:j+bbb-1)=reshape((DA(cc,:))',bbb,bbb);
        cc=cc+1;
    end
end
cc = 1;
for i = ((n + (bbb - 1) * betweenBlockMargin) + 6) :...
        bbb + jy :...
        ((bbb - 1) * (bbb + jy) ) + ((n + (bbb - 1) * betweenBlockMargin) + 6)
    for j=1:bbb + jy:((bbb - 1) * (bbb + jy))+1
        Td(i:i+bbb-1,j:j+bbb-1)=reshape((DA(cc,:))',bbb,bbb);
        cc=cc+1;
    end
end
end


