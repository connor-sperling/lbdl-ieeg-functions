function [beg_msk, end_msk] = split_stroop_evns_R(evns, clr, spc, k)

    if ~iscell(evns{1})
        evn_split = cellfun(@(x) strsplit(x, '-'), evns, 'UniformOutput', false);
    else
        evn_split = evns;
    end
    
    beg_msk = cellfun(@(x) strcmp(x{3}, clr) & strcmp(x{4}, spc) & str2double(x(1))-40*(k-1)-k < 21, evn_split);
    end_msk = cellfun(@(x) strcmp(x{3}, clr) & strcmp(x{4}, spc) & str2double(x(1))-40*(k-1)-k > 20, evn_split);

end