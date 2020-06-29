
clear
xldir = '/Volumes/LBDL Extern/bdl-raw/iEEG_San_Diego/Materials/Verbgen stim/ratings';
verbsin = readtable(sprintf('%s/results.xlsx', xldir));

Entropy = zeros(size(verbsin,1),1);

for ii = 1:size(verbsin,1)
    vx = table2cell(verbsin(ii,:));
    uvx = unique(vx);
    numall = [];
    
    for kk = 1:length(uvx)
        numv = sum(cellfun(@(x) strcmp(x,uvx{kk}), vx));
        numall = [numall numv];
    end
    pall = numall./length(vx);
    ent = -sum(pall.*log2(pall));
    Entropy(ii) = ent;
    
end

verbsout = addvars(verbsin, Entropy);
writetable(verbsout, sprintf('%s/results.xlsx',xldir));