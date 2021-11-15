function stroop_task_congruency_analysis(EEG, study, pth, cmat) 

% Initiates significance testing and splits stroop events based on two
% conditions: Congruent in task (Color or Spatial) and Incongruent in task
% 
    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
    
    adat_pth = sprintf('%s/ALL/data/%s', pth, EEG.band);
    fdat_pth = sprintf('%s/condition/data/%s', pth, EEG.band);
    
    segment_events_per_channel(EEG, adat_pth, 'ALL') 
    TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', pth), 'ALL');
    
    if isempty(TvD)
        fprintf('\nNo significant channels found\n');
        return
    end
    
    % remove insignificant channels from data
    sig_lab = TvD(:,2);
    all_lab = {EEG.chanlocs.labels}';
    ses_dat = [EEG.data]; % 'session data'
    ses_dat(~ismember(all_lab, sig_lab), :) = []; % delete rows for channels
                                                      % not found significant

    % temporary, 'session' EEG with only significant data
    ses_EEG = make_EEG(EEG, 'dat', ses_dat, 'labels', sig_lab);
    ses_EEG.band = EEG.band;
    ses_EEG.lock = EEG.lock;   
        
    evn_split = cellfun(@(x) strsplit(x, '-'), evn, 'UniformOutput', false);
    blk_idx = 2;
    max_block = str2double(evn_split{end}{blk_idx});
    
    color_idx = 3;
    space_idx = 4;
    
%     conditions = {'C', 'I'};
    conditions = {'Color', 'Space'};
    for n = 1:length(conditions)
        cond = conditions{n};
        c_cond_evns = {}; s_cond_evns = {};
        c_cond_evn_idcs = []; s_cond_evn_idcs = [];
        c_cond_resp = []; s_cond_resp = [];
        
        % Splitting events by task AND congruency
%         for ii = 1:max_block
%             blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
%             block_evns = evn(blk_msk);
%             block_idcs = evn_idc(blk_msk);
%             block_resp = rtm(blk_msk);
%             
%             block_evn_split = cellfun(@(x) strsplit(x, '-'), block_evns, 'uni', 0);  
%             if mod(ii,2)   
%                 msk = cellfun(@(x) strcmp(x{color_idx}, cond), block_evn_split);
%                 c_cond_evns = [c_cond_evns; block_evns(msk)];
%                 c_cond_evn_idcs = [c_cond_evn_idcs; block_idcs(msk)];
%                 c_cond_resp = [c_cond_resp; block_resp(msk)];
%             else
%                 msk = cellfun(@(x) strcmp(x{space_idx}, cond), block_evn_split);
%                 s_cond_evns = [s_cond_evns; block_evns(msk)];
%                 s_cond_evn_idcs = [s_cond_evn_idcs; block_idcs(msk)];
%                 s_cond_resp = [s_cond_resp; block_resp(msk)];
%             end
%             
%         end   
%         ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', c_cond_evn_idcs,...
%                                         'AnalysisEventType', c_cond_evns,...
%                                         'AnalysisResponseTime', c_cond_resp);
% %         segment_events_per_channel(ses_EEG, fdat_pth, sprintf('%s-color', cond))
%         segment_events_per_channel(ses_EEG, fdat_pth, cond)
%         
%         ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', s_cond_evn_idcs,...
%                                         'AnalysisEventType', s_cond_evns,...
%                                         'AnalysisResponseTime', s_cond_resp);
% %         segment_events_per_channel(ses_EEG, fdat_pth, sprintf('%s-space', cond))
%         segment_events_per_channel(ses_EEG, fdat_pth, cond)
%         
%     end
        
    % Splitting events by task
    for ii = 1:max_block
        blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
        block_evns = evn(blk_msk);
        block_idcs = evn_idc(blk_msk);
        block_resp = rtm(blk_msk);

        if mod(ii,2)   
            c_cond_evns = [c_cond_evns; block_evns];
            c_cond_evn_idcs = [c_cond_evn_idcs; block_idcs];
            c_cond_resp = [c_cond_resp; block_resp];
        else
            s_cond_evns = [s_cond_evns; block_evns];
            s_cond_evn_idcs = [s_cond_evn_idcs; block_idcs];
            s_cond_resp = [s_cond_resp; block_resp];
        end

    end   

    ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', c_cond_evn_idcs,...
                                    'AnalysisEventType', c_cond_evns,...
                                    'AnalysisResponseTime', c_cond_resp);
%         segment_events_per_channel(ses_EEG, fdat_pth, sprintf('%s-color', cond))
    segment_events_per_channel(ses_EEG, fdat_pth, 'Color')

    ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', s_cond_evn_idcs,...
                                    'AnalysisEventType', s_cond_evns,...
                                    'AnalysisResponseTime', s_cond_resp);
%         segment_events_per_channel(ses_EEG, fdat_pth, sprintf('%s-space', cond))
    segment_events_per_channel(ses_EEG, fdat_pth, 'Space')
        
    
    sig_lab = TvD(:,2);
    cd(fdat_pth)
    for ii = 1:length(sig_lab)
        chan_mats_struc = dir(['*' sig_lab{ii} '*']);
        channel_mats = {chan_mats_struc.name};
        plot_conditions(ses_EEG, channel_mats, sig_lab{ii}, study, cmat)
    end
    
end