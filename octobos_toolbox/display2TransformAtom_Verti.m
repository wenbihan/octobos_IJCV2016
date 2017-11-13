%% plot 2  blocks of OCTOBOS

n = 81;
margin_vert = 0;
margin_hori =5;
margin_between = 8;
DA = transform(:, :, 1);
DB = transform(:, :, 2);
t = max(max(max(DA)), max(max(DB)));            
bb = sqrt(n);

% generate the visualization image
% 1st transform
width = n + 2 * (bb - 1);
Td = t * ones(width, width);
jy=2;cc=1;
for i=1:bb + jy:((bb - 1)*(bb+jy))+1
    for j=1:bb+jy:((bb - 1)*(bb + jy))+1
        Td(i:i+(bb - 1),j:j+(bb - 1))=reshape((DA(cc,:))',sqrt(n),sqrt(n));
        cc=cc+1;
    end
end
imagesc(Td);colormap('Gray');axis off;axis image;
% 2nd transform
jy=2;cc=1;
Te = t * ones(width, width);
for i=1:bb + jy:((bb - 1)*(bb+jy))+1
    for j=1:bb+jy:((bb - 1)*(bb + jy))+1
        Te(i:i+(bb - 1),j:j+(bb - 1))=reshape((DB(cc,:))',sqrt(n),sqrt(n));
        cc=cc+1;
    end
end

T_total = t * ones(width * 2 + margin_between + margin_hori*2, width + margin_vert * 2);
T_total(margin_hori + 1: margin_hori + width, margin_vert + 1:width + margin_vert) = Td;
T_total(margin_vert + 1:width + margin_vert, margin_hori + width + margin_between + 1 : end - margin_hori) = Te;


figure; imagesc(T_total);colormap('Gray');axis off;axis image;