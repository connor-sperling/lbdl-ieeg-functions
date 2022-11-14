function stroop_NR_analysis(EEG, study, pth) 
    
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
    
    % find significant channels, make stucture that only contains sig dat
    sig_chans = string(TvD(:,2));
    all_chans = string({EEG.chanlocs.labels}');
    ses_dat = [EEG.data];
    ses_dat(~ismember(all_chans, sig_chans), :) = [];

    ses_EEG = make_EEG(EEG, 'dat', ses_dat, 'labels', TvD(:,2));
    ses_EEG.band = EEG.band;
    ses_EEG.lock = EEG.lock;
        
    evn_split = cellfun(@(x) strsplit(x, '-'), evn, 'UniformOutput', false);
    blk_idx = 2;
    max_block = str2double(evn_split{end}{blk_idx});
    
    color_idx = 3;
    space_idx = 4;
    
    for N = 1:4
        c_beg = {}; c_end = {}; 
        s_beg = {}; s_end = {};
        c_beg_idcs = []; c_end_idcs = [];
        s_beg_idcs = []; s_end_idcs = [];
        c_beg_resp = []; c_end_resp = []; 
        s_beg_resp = []; s_end_resp = [];
        switch N
            case 1
                stroop_idx = color_idx;
                cong = 'C';
                stp = 'c';
            case 2
                stroop_idx = color_idx;
                cong = 'I';
                stp = 'c';
            case 3
                stroop_idx = space_idx;
                cong = 'C';
                stp = 's';
            case 4
                stroop_idx = space_idx;
                cong = 'I';
                stp = 's';
        end

        
        for ii = 1:max_block
            blk_msk = cellfun(@(x) str2double(x(blk_idx)) == ii, evn_split);
            block_evns = evn(blk_msk);
            block_idcs = evn_idc(blk_msk);
            block_resp = rtm(blk_msk);
            [beg_msk,end_msk] = split_stroop_evns_NR(block_evns, stroop_idx, cong, ii);
            if mod(ii,2)            
                c_beg = [c_beg; block_evns(beg_msk)];
                c_end = [c_end; block_evns(end_msk)];
                c_beg_idcs = [c_beg_idcs; block_idcs(beg_msk)];
                c_end_idcs = [c_end_idcs; block_idcs(end_msk)];
                c_beg_resp = [c_beg_resp; block_resp(beg_msk)];
                c_end_resp = [c_end_resp; block_resp(end_msk)];
            else
                s_beg = [s_beg; block_evns(beg_msk)];
                s_end = [s_end; block_evns(end_msk)];
                s_beg_idcs = [s_beg_idcs; block_idcs(beg_msk)];
                s_end_idcs = [s_end_idcs; block_idcs(end_msk)];
                s_beg_resp = [s_beg_resp; block_resp(beg_msk)];
                s_end_resp = [s_end_resp; block_resp(end_msk)];
            end
        end
        
        
        prompt('stroop evn prep', 4*(N-1)+1, 'Beg', 'c', cong, stp)
        ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', c_beg_idcs,...
                                        'AnalysisEventType', c_beg,...
                                        'AnalysisResponseTime', c_beg_resp);
        segment_events_per_channel(ses_EEG, fdat_pth, ['c' cong stp 'Beg'])
        
        prompt('stroop evn prep', 4*(N-1)+2, 'End', 'c', cong, stp)
        ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', c_end_idcs,...
                                        'AnalysisEventType', c_end,...
                                        'AnalysisResponseTime', c_end_resp);
        segment_events_per_channel(ses_EEG, fdat_pth, ['c' cong stp 'End'])
        
        prompt('stroop evn prep', 4*(N-1)+3, 'Beg', 's', cong, stp)
        ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', s_beg_idcs,...
                                        'AnalysisEventType', s_beg,...
                                        'AnalysisResponseTime', s_beg_resp);
        segment_events_per_channel(ses_EEG, fdat_pth, ['s' cong stp 'Beg'])
        
        prompt('stroop evn prep', 4*(N-1)+4, 'End', 's', cong, stp)
        ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', s_end_idcs,...
                                        'AnalysisEventType', s_end,...
                                        'AnalysisResponseTime', s_end_resp);
        segment_events_per_channel(ses_EEG, fdat_pth, ['s' cong stp 'End'])
        
    end
    
    sig_chans = TvD(:,2);
    cd(fdat_pth)
    prompt('stroop plot')
    for ii = 1:length(sig_chans)
%         loadbar(ii, length(sig_chans));
        chan_mats_struc = dir(['*' sig_chans{ii} '*']);
        channel_mats = {chan_mats_struc.name};
        plot_stroop_NR(EEG, channel_mats, study, ii);
    end
    
end