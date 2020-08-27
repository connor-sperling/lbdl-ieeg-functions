function events_by_condition_modular(EEG, pth, study, arg, conditions, cmat) 

    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
              
    adat_pth = sprintf('%s/ALL/data/%s', pth, EEG.band);
    fdat_pth = sprintf('%s/condition/data/%s', pth, EEG.band);
    
    % convert channel data into matricies of event resonses
    segment_events_per_channel(EEG, evn, evn_idc, rtm, adat_pth, 'ALL') 

    % Perform statistical analysis to find significant channels
%     TvD = sig_freq_band(EEG, rtm, sprintf('%s/ALL', pth), 'ALL');
    TvD = significant_electrode_zscore(EEG, rtm, sprintf('%s/ALL', pth), 'ALL');

%     TvD = sig_electrode_pwr(EEG, rtm, sprintf('%s/ALL', pth), 'ALL');

    sig_chans = string(TvD(:,2)); % list of significant channels
    all_chans = string({EEG.chanlocs.labels}'); % all channels
    ses_dat = [EEG.data];
    ses_dat(~ismember(all_chans, sig_chans), :) = []; % delete rows for channels
                                                      % not found significant

    % temporary, 'session' EEG with only significant data
    ses_EEG = make_EEG(EEG, 'dat', ses_dat, 'labels', TvD(:,2));
    ses_EEG.band = EEG.band;
    ses_EEG.lock = EEG.lock;

    sig_all = TvD(:,2);

    [Evns, Evnis, Rtms] = modular_evn_split(arg, evn, evn_idc, rtm, 'filt', '*-mod(*,2)==0-*-*-*-*');
    for i = 1:length(conditions)
        segment_events_per_channel(ses_EEG, Evns{i}, Evnis{i}, Rtms{i}, fdat_pth, conditions{i});
    end

    % plot
    cd(fdat_pth)
    for ii = 1:length(sig_all)
        chan_mats_struc = dir(sprintf('*%s_%s*', sig_all{ii}, EEG.ref));
        channel_mats = {chan_mats_struc.name};
        plot_conditions(EEG, channel_mats, sig_all{ii}, study, cmat);
    end
    
end



