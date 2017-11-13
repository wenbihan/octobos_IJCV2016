function [param] = OCTOBOS_imagedenoise_param(param)
%Function for tuning paramters for OCTOBOS denoising
%
%Note that all input parameters need to be set prior to simulation. 
%This tuning function is just an example settings which we provide, for 
%generating the results in the "OCTOBOS paper". However, the user is
%advised to carefully modify this function, thus choose optimal values  
%for the parameters depending on the specific data or task at hand.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = param.n;
sig = param.sig;
K = param.numBlock;
%% constant     -   C1
% (1) The following setup is to reproduce the results in IJCV2016
% switch n
%     case 64
%         C1=1.08; 
%     case 81
% 		C1=1.07; 
%     case 121
% 		C1=1.04; 
%     case 144
%         C1 = 1.03;
%     case 225
%         C1 = 1.015;    
%     otherwise
%         C1 = 1.08;      % Incase the patch size is not one of these values.
% end
% (2) The following setup is used in general 
if sqrt(n) <= 8
    C1 = 1.08;
elseif sqrt(n) <= 9
    C1 = 1.07;
elseif sqrt(n) <= 10
    C1 = 1.05;
elseif sqrt(n) <= 11
    C1 = 1.04;
elseif sqrt(n) <= 12
    C1 = 1.03;
elseif sqrt(n) <= 15
    C1 = 1.015;
elseif sqrt(n) <=20
    C1 = 1.01;
else
    C1 = 1.0;
end
%% multi-pass denoising signal list     -   sig2, sigma list used in multipass
% (1) The following setup is to reproduce the results in IJCV2016
% switch sig
%     case 5
%         sig2 = [5];
%     case 10
% 		sig2 = [9,3];
%     case 15
% 		sig2 = [13.5, 3, 1.5, 0.8];
%     case 20
% 		sig2 = [18,4,2];
%     case 100
% 		sig2 = [90,20,4,3];       
%     otherwise
%         sig2 = sig;
% end
% (2) The following setup is used in general
if sig <= 8
    sig2 = sig;
elseif sig <= 12
    sig2 = [sig*0.9, sig/3];
elseif sig <= 17
    sig2 = [sig*0.9, sig*0.2, sig*0.1, sig*0.05];
elseif sig <= 50
    sig2 = [sig*0.9, sig*0.2, sig*0.1];
else
    sig2 = [sig*0.9, sig*0.2, sig*0.04, sig*0.03];
end

%% coefficient  -   la
la = 0.01/sig;
%% initial sparsity     -   T0
T0 = round((0.1)*n);
%% initial OCTOBOS   -   transform
% Transform Initialization: DCT
D = kron(dctmtx(sqrt(n)),dctmtx(sqrt(n)));          
Dc = zeros(n,n,param.numBlock);
for i = 1:K
    Dc(:,:,i)=D;
end
%% number of iteration    -   iter
if (sig > 50) 
    iter = 7;
else 
    iter = 25;
end

param.C1 = C1;
param.sig2 = sig2;
param.la = la;
param.T0 = T0;
param.transform = Dc;
param.iter = iter;
param.l0 = 0.031;
param.iterMultipass = 3;
param.roundLearning = 12;
param.maxClusterSize = 22400*1.43;

end

