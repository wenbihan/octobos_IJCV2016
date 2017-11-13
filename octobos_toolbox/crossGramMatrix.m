function [crossGram] = crossGramMatrix(DA, DB, DC, DD)
%% normalize row
DA = (DA./(ones(size(DA,2),1)*sqrt(sum(DA'.^2)))');
DB = (DB./(ones(size(DB,2),1)*sqrt(sum(DB'.^2)))');
DC = (DC./(ones(size(DC,2),1)*sqrt(sum(DC'.^2)))');
DD = (DD./(ones(size(DD,2),1)*sqrt(sum(DD'.^2)))');
A1=[DA;DB];
A2=[DC;DD];
A1 = (A1./(ones(size(A1,2),1)*sqrt(sum(A1'.^2)))');
A2 = (A2./(ones(size(A2,2),1)*sqrt(sum(A2'.^2)))');
crossGram = A1 * A2';
% figure();imagesc(abs(crossGram)); axis off; axis image; colorbar; set(gca, 'FontSize',24);
end


