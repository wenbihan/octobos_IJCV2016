function [ updateTransform ] = transformUpdate(TE, sparseCode, transform, l2, l3 )
%transformUpdate Summary:

% function is the closed-form update of the square transform

% Inputs -
%       1. TE : Image patch data - an nXN matrix that contins N signals,
%       each of dimension n. 
%
%       2. sparseCode: an nXN matrix that contins N sparse codes,
%       each of dimension n.
%
%       3. transform : Initial square transform - an nXn matrix.
%
%       4. l2, l3: weights on regularizer term (Example: l2 = l3)
%
        n=size(transform,2); 
        [U,S,V]=svd((TE*TE') + (l3*eye(n)));
        LL=U*(S^(1/2))*V';
        LL2=(inv(LL));        
        [Q1,Si,R]=svd(LL2*TE*sparseCode');
        sig=diag(Si);
        gamm=(1/2)*(sig + (sqrt((sig.^2) + 2*l2)));
        B=R*(diag(gamm))*Q1';
        updateTransform=B*(LL2);
end

