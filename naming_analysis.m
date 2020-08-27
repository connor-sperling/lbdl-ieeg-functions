function naming_analysis(EEG, study, pth, cmat) 


    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
    
    adat_pth = sprintf('%s/ALL/data/%s', pth, EEG.band);

    segment_events_per_channel(EEG, adat_pth, 'ALL') 
    TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', pth), 'ALL');

    sig_chans = string(TvD(:,2));
    all_chans = string({EEG.chanlocs.labels}');
    ses_dat = [EEG.data];
    ses_dat(~ismember(all_chans, sig_chans), :) = [];
    
    ses_EEG = make_EEG(EEG, 'dat', ses_dat, 'labels', TvD(:,2));
    ses_EEG.band = EEG.band;
    ses_EEG.lock = EEG.lock;
    
    
    evn_split = cellfun(@(x) strsplit(x, '-'), evn, 'UniformOutput', false);
    positions = cellfun(@(x) x(2), evn_split);
    keyset = unique(positions);
  
    gsize = 2;
    k = 1;
    prompt('naming evn analysis', num2str(gsize))
    fdat_pth = sprintf('%s/condition/data/%s/Group Size %d', pth, EEG.band, gsize);
    my_mkdir(fdat_pth, '*.mat');
    while k <= length(keyset)

        if k == k+gsize-1
            pcatn = ['poscat' keyset{k}];
        else
            pcatn = ['poscat' keyset{k} '-' num2str(k+gsize-1)];
        end

        focus_evn_typ = {}; focus_evn_idc = []; focus_resp = [];
        for ii = k:k+gsize-1
            temp_typ = evn(ismember(positions, keyset(ii)));
            temp_evns_idc = evn_idc(ismember(evn, temp_typ));
            temp_resp = rtm(ismember(evn, temp_typ));

            focus_evn_typ = [focus_evn_typ; temp_typ];
            focus_evn_idc = [focus_evn_idc; temp_evns_idc];
            focus_resp = [focus_resp; temp_resp];
        end
        
        ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', focus_evn_idc, 'AnalysisEventType', focus_evn_typ, 'AnalysisResponseTime', focus_resp);
        segment_events_per_channel(ses_EEG, fdat_pth, pcatn);

        k = k + gsize;
    end

    handles = {};
    axiis = {};
    cd(fdat_pth)
    for ii = 1:length(sig_chans)
        chan_mats_struc = dir(['*' sig_chans{ii} '*']);
        channel_mats = {chan_mats_struc.name};
        axii = plot_naming_poscat(EEG, channel_mats, sig_chans{ii}, gsize, study, ii, cmat);

        handles{ii} = get(axii, 'children');
        axiis{ii} = axii;
    end

%     subplot_all(handles, axiis, 4, [lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize) '/'])

end



