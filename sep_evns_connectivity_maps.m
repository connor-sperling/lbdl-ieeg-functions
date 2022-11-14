function [A_deck_cond, evn_cond] = sep_evns_connectivity_maps(A_deck, evn, cond, separation)


    evn_split = cellfun(@(x) strsplit(x, '-'), evn, 'uni', 0);

    blk_idx = 2;
    color_idx = 3;
    space_idx = 4;

    max_block = max(cellfun(@(x) str2double(x{blk_idx}), evn_split));
    evn_condition = {};

    if contains(cond, '-')
        cond_splt = strsplit(cond, '-');
        cond = cond_splt{1}; stroop = cond_splt{2};
    end
    
    switch separation
        case 'ALL'
            evn_condition = evn;
            
        % Separates events into congruent object in task and incongruent
        % object in task. Does not distinguish between Color/Spatial Stroop
        case 'TaskCongruency'
            for ii = 1:max_block
                blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
                block_evn = evn(blk_msk);
                block_evn_split = cellfun(@(x) strsplit(x, '-'), block_evn, 'uni', 0);  
                if mod(ii,2)   
                    stroop_idx = color_idx;
                else
                    stroop_idx = space_idx;
                end
                msk = cellfun(@(x) strcmp(x{stroop_idx}, cond), block_evn_split);
                evn_condition = [evn_condition; block_evn(msk)];
            end   
            
        % Separates events by Congruency/Incongruency w.r.t. sub task (e.g.
        % congruent events in color stroop vs. incongruent events in
        % spatial stroop vs. etc.)
        case 'SubTaskCongruency'
            for ii = 1:max_block
                blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
                block_evn = evn(blk_msk);
                block_evn_split = cellfun(@(x) strsplit(x, '-'), block_evn, 'uni', 0);  
                if strcmpi(stroop, 'color') && mod(ii,2)
                    msk = cellfun(@(x) strcmp(x{color_idx}, cond), block_evn_split);
                    evn_condition = [evn_condition; block_evn(msk)];
                elseif strcmpi(stroop, 'space') && ~mod(ii,2)
                    msk = cellfun(@(x) strcmp(x{space_idx}, cond), block_evn_split);
                    evn_condition = [evn_condition; block_evn(msk)];
                end

            end 
            
        % Separates events into Color Stroop and Spatial Stroop events
        case 'SubTask'
            for ii = 1:max_block
                blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
                block_evn = evn(blk_msk);
%                 block_evn_split = cellfun(@(x) strsplit(x, '-'), block_evn, 'uni', 0);  
                if strcmpi(cond, 'color') && mod(ii,2)
                    evn_condition = [evn_condition; block_evn];
                elseif strcmpi(cond, 'space') && ~mod(ii,2)
                    evn_condition = [evn_condition; block_evn];
                end
            end  
            
    end  
    evn_msk = ismember(evn, evn_condition);
    evn_cond = evn(evn_msk);
    A_deck_cond = A_deck(:,:,evn_msk);
end