function evn_cond_files = sep_evns_connectivity_maps(evn_files, cond, separation)

% just writing code for separating congruent in task vs. incong. in task

    evn_file_splt = cellfun(@(x) strsplit(x,'_'), evn_files, 'uni', 0);
    evns = cellfun(@(x) x{5}, evn_file_splt, 'uni', 0);
    evn_split = cellfun(@(x) strsplit(x, '-'), evns, 'uni', 0);

    blk_idx = 2;
    color_idx = 3;
    space_idx = 4;

    max_block = max(cellfun(@(x) str2double(x{blk_idx}), evn_split));
    evn_condition = {};

    switch separation
        case 'ALL'
            evn_condition = evns;
            
        case 'TaskCongruency'
            for ii = 1:max_block
                blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
                block_evns = evns(blk_msk);
                block_evn_split = cellfun(@(x) strsplit(x, '-'), block_evns, 'uni', 0);  
                if mod(ii,2)   
                    stroop_idx = color_idx;
                else
                    stroop_idx = space_idx;
                end
                msk = cellfun(@(x) strcmp(x{stroop_idx}, cond), block_evn_split);
                evn_condition = [evn_condition block_evns(msk)];
            end   
    end  
    evn_msk = ismember(evns, evn_condition);
    evn_cond_files = evn_files(evn_msk);
end