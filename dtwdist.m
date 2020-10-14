% function d = dtwdist(X, varargin)
% [n,~] = size(X);
% % preallocate
% d = zeros(m,1);
% 
% for i = 1:n
%     for j=i+1:n
%         d(j) = dtw(X(i,:), X(j,:));
%     end
% end
% end

function d = dtwdist(Xi, Xj, varargin)
[m,n] = size(Xj);
% preallocate
d = zeros(m,1);
for j=1:m
    d(j) = dtw(Xi, Xj(j,:), varargin{:});
end