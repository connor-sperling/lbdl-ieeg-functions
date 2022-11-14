function [latent, latentLow, latentHigh] = paran(x, nShuffle, alpha, varargin)
% Parallel Analysis (PA) to for determining the number of components to
% retain from PCA. component is retained if the associated eigenvalue is bigger than the 95th of the distribution of eigenvalues derived from the random data.
% Syntax:
% ======
% pa_test(x, nShuffle, alpha, princomp_parameters[ ])
%       x - the data matrix (nXp where n is the number of observation and p is dimension of each observation)
%       nShuffle - number of shuffles. optional, default = 100
%       alpha - significance level. optional, default 0.05
%       princomp_parameters - parameters to pass to the princomp function (see help princomp). optional, default ={true,'Centered',false}

% Background:
% ==========
% From Wikipedia: http://en.wikipedia.org/wiki/Factor_analysis
% Horn's Parallel Analysis (PA):
% A Monte-Carlo based simulation method that compares the observed eigenvalues with those obtained from uncorrelated normal variables.
% A factor or component is retained if the associated eigenvalue is bigger than the 95th of the distribution of eigenvalues derived from the random data.
% PA is one of the most recommendable rules for determining the number of components to retain, but only few programs include this option.

% References:
% * Ledesma, R.D.; Valero-Mora, P. (2007). "Determining the Number of Factors to Retain in EFA: An easy-to-use computer program for carrying out Parallel Analysis". Practical Assessment Research & Evaluation 12 (2): 1–11.


if ~exist('nShuffle', 'var')
        nShuffle = 100;
end
if ~exist('alpha', 'var')
        alpha = 0.05;
end
x = x';
[~,~,latent] = pca(x);

for i = 1:nShuffle 
[~,p] = sort(rand(size(x,2),size(x,1)),2); 
ind = sub2ind(size(x),p',ones(size(x,1),1)*(1:size(x,2))); 
xShuffle = x(ind); 
[~, ~ ,latentShuffle(:,i)] = pca(xShuffle); 
end 

latentHigh = quantile(latentShuffle', 1-alpha);
latentLow = quantile(latentShuffle', alpha);
latentMean = mean(latentShuffle,2);
if nargout == 0
    plot(latent,'bo-');
    hold on;
    plot(latentHigh,'ro-');
    plot(latentLow,'go-');
    plot(latentMean,'ko-');
    hold off;
    legend('data',sprintf('shuffled %d%%', 100*(1-alpha)),sprintf('shuffled %d%%', 100*alpha));
end

