function [gramMat] = gramMatrix(DA, DB)
% normalization
DA = (DA./(ones(size(DA,2),1)*sqrt(sum(DA'.^2)))');
DB = (DB./(ones(size(DB,2),1)*sqrt(sum(DB'.^2)))');
gramMat = DA * DB';
% figure();imagesc(abs(gramMat)); axis off; axis image; colorbar; set(gca, 'FontSize',24);
end


