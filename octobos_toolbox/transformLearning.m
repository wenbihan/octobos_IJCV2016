function [transform, sparseCode] = transformLearning(TE, transform, l2, l3, STY, roundLearning)
%function is to learn transform based sparse representation
%
% function is alternating between transform update and sparse coding to
% train a square sparsifying transform.
%
% Inputs -
%       1. TE : Image patch data - an nXN matrix that contins N signals,
%       each of dimension n. 
%
%       2. transform : Initial square transform - an nXn matrix.
%
%       3. l2, l3: Weights on regularizer term (Example: l2 = l3)
%        
%       4. STY: Initial Sparsities
%        
%       5. roundLearning: number of alternations in the learning
%
% Outputs -
%       1. transform : The learned square transform 
%
%       2. sparseCode: The corresponding sparse codes

for roundLearning = 1 : roundLearning
    sparseCode = sparseSTY(transform * TE, STY);
    transform = transformUpdate(TE, sparseCode, transform, l2, l3);
end
end

