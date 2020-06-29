%function MULTI_import_MGH_data
% Bipolar reference example
%
% Burke Rosen 2019-01-15



%% find seeg shafts
% load('original_labels.mat'); % these are in edf header
% lab = original_labels;
lab = tlab;
alph = cellfun(@(x) x(isstrprop(x,'alpha')),lab,'uni',0);
numr = cellfun(@(x) str2double(x(isstrprop(x,'digit'))),lab,'uni',0);

[~,~,shftIdx] = unique(alph,'stable');
seegMsk = false(size(lab));
for sI = 1:max(shftIdx)
  sMsk = shftIdx==sI;
  if sum(sMsk)>=2 && all(diff([numr{sMsk}])==1)
    % assumes each shaft >=2 contacts and that the contact #'s count up by 1's
    % assumes contact numbers are always ascending
    seegMsk(sMsk) = true;
  end
end

alph = alph(seegMsk);
numr = numr(seegMsk);
[shftLabs,~,shftIdx] = unique(alph,'stable');

%% make fake data 
% this would be loaded from edf
%%% for debugging
% dat = shftIdx'.*ones(1000,118);% use to test whether any inter-shaft subtractions occur
% dat(:,2) = 2; % use to test 2-1 subtraction order
%%%
dat = tdat;

%% Perform bipolar rereferencing
ddat = diff(dat,1,1) % 2-1, 3-2
dIdx = find(diff(shftIdx))
ddat(dIdx,:) = []%remove intershaft derived channels

% get bipolar labels
dlab = alph
dlab(dIdx) = []
dnumr = numr
dnumr([dIdx+1]) = []
dlab = cellfun(@(x,y) sprintf('%s%.2i-%.2i',x,y,y-1),dlab,dnumr,'uni',0)
dlab(1) = [];








