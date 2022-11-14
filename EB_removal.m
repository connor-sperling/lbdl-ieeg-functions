function Y = EB_removal(X)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:
% 
% X     :     MxN input signals. 
%             N: Number of samples, M: Number of channels 
%
% Outputs:
%
% Y     :     MxN signals with no artifacts.
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N,M] = size(X);
YY = zeros(N,M);

for  n=1:N
    x = X(n,:);
    x_peak = max(abs(x));
    x = x/x_peak;
    
    params.x = x;
    params.blocksize = 100;
    params.dictsize = 150;
    params.trainnum = 500;
    params.sigma = 0.1;
    
    [y,~,~] = ksvddenoise(params,0);
    
    YY(n,:) = y*x_peak;
    
end

Y = YY-X;