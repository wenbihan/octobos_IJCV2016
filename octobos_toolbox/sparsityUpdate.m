function [STY, q] = sparsityUpdate(TE, Dc, la, threshold, SP)
%SPARSITYUPDATE Summary of this function goes here
%   Detailed explanation goes here
% initialization
n = size(TE, 1);
X1 = Dc * TE;
kT = zeros(1, size(TE, 2));
[~, ind]=sort(abs(X1), 'descend');
er = n * (0 : (size(X1, 2) - 1));
ind = ind + (er' * ones(1, n))';
G = (pinv([(sqrt(la) * eye(n)); Dc]));
Ga = G(:, 1 : n);
Gb = G(:, (n+1) : (n+n));
Gz = Ga*((sqrt(la)) * TE);

q = Gz;
ZS2 = sqrt(sum((Gz - TE).^2)); 
kT = kT + (ZS2 <= threshold);
STY = zeros(1, size(TE, 2));
X = zeros(n, size(TE, 2));
for ppp = 1 : length(SP)
    indi=find(kT==0);
    if(isempty(indi))
        break;
    end
    X(ind(ppp,indi)) = X1(ind(ppp,indi));
    q(:,indi) = Gz(:,indi) + Gb*(X(:,indi));            % q is the reconstructed data
    ZS2 = sqrt(sum((q(:,indi) - TE(:, indi)).^2)); 
    kT(indi) = kT(indi)+(ZS2<=threshold);               %vector kT takes value 1 where threshold is satisfied
    STY(indi) = ppp;                                    %STY stores new sparsity levels
end
end

