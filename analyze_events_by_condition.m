function analyze_events_by_condition(EEG, id_name, idents, pth, study, cmat) 

    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
              
    adat_pth = sprintf('%s/ALL/data/%s', pth, EEG.band); % path to save 'ALL' data
    fdat_pth = sprintf('%s/condition/data/%s', pth, EEG.band); % path to save 'condition' data
    

    % convert channel data into matricies of event resonses
    segment_events_per_channel(EEG, adat_pth, 'ALL') 

    % Perform statistical analysis to find significant channels
    TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', pth), 'ALL');

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
    
    if isempty(sig_lab)
        disp('  ')
        disp('  No significant channels found')
    else
        for i = 1:length(idents)
            grp = idents{i};
            foc_nm = sprintf('%s-%s', id_name, grp);

            % find events that fall into a ceratain category of event name
            id_msk = cellfun(@(x) contains(x, grp), evn); 

            % event names/indicies/response times that correspond to the condition
            fevn = evn(id_msk); 
            fevn_idc = evn_idc(id_msk);
            frtm = rtm(id_msk);

            ses_EEG = make_EEG(ses_EEG, 'AnalysisEventIdx', fevn_idc,...
                                        'AnalysisEventType', fevn,...
                                        'AnalysisResponseTime', frtm);

            segment_events_per_channel(ses_EEG, fdat_pth, foc_nm);
        end

        % plot
        cd(fdat_pth)
        for ii = 1:length(sig_lab)
            mats_struc = dir(sprintf('*%s_%s*', sig_lab{ii}, EEG.ref));
            channel_mats = {mats_struc.name};
            plot_conditions(EEG, channel_mats, sig_lab{ii}, study, cmat);
        end
    end
end



