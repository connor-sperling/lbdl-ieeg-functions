function events_by_condition(EEG, id_name, idents, pth, study, sep_an, cmat) 

    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
              
    adat_pth = sprintf('%s/ALL/data/%s', pth, EEG.band);
    fdat_pth = sprintf('%s/condition/data/%s', pth, EEG.band);
    
    % Two methodologies: Group all events together ('ALL') and find channels
    % exhibiting significant activity, or separate events based on some
    % condition ('condition') and find significant channels from each set
    if ~sep_an % 'ALL'
        % convert channel data into matricies of event resonses
        channel_by_event(EEG, evn, evn_idc, rtm, adat_pth, 'ALL') 
        
        % Perform statistical analysis to find significant channels
        TvD = sig_freq_band(EEG, rtm, sprintf('%s/ALL', pth), 'ALL');

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
    else % 'condition'
        sig_all = {};
    end
        
    for i = 1:length(idents)
        grp = idents{i};
        foc_nm = sprintf('%s-%s', id_name, grp);
        
        % find events that fall into a ceratain category of event name
        id_msk = cellfun(@(x) contains(x, grp), evn); 
        
        % Filter event information
        fevn = evn(id_msk); 
        fevn_idc = evn_idc(id_msk);
        frtm = rtm(id_msk);
        
        if ~sep_an % 'ALL'
            channel_by_event(ses_EEG, fevn, fevn_idc, frtm, fdat_pth, foc_nm);
        else % 'condition'
            channel_by_event(EEG, fevn, fevn_idc, frtm, fdat_pth, foc_nm);
            TvD = sig_freq_band(EEG, frtm, sprintf('%s/condition', pth), foc_nm);
            sig_all = [sig_all; TvD(:,2)];
        end
    end

    % plot
    cd(fdat_pth)
    for ii = 1:length(sig_all)
        chan_mats_struc = dir(sprintf('*%s_%s*', sig_all{ii}, EEG.ref));
        channel_mats = {chan_mats_struc.name};
        plot_conditions(EEG, channel_mats, sig_all{ii}, study, cmat);
    end
    
end



