function events_by_density(EEG, pth, study) 

    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
    
    event_prep(EEG, evn_idc, rtm, all_chan_pth, 'ALL') 
    sig_freq_band(EEG, rtm, all_pth, 'ALL');

    ses_TvD = sprintf('%s/ALL/TvD/ALL_%s_TvD.mat', pth, band);
    if exist(ses_TvD, 'file')
        load(ses_TvD, 'TvD')
    else
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
    evn_den = cellfun(@(x) x(3), evn_split);  
    densities = {'HD', 'LD'}';
    for d = 1:length(densities)
        den = densities{d};
        k = 1;
        cat_pth = sprintf('%s/Data by Position in Category/%s', pth, EEG.band{end});
        
        if ~exist(cat_pth, 'dir')
            mkdir(cat_pth)
        elseif k == 1
            fp = dir(fullfile(cat_pth, '*.mat'));
            mfiles = {fp.name};
            for m = 1:length(mfiles)
                delete([cat_pth mfiles{m}]);
            end
        end
        
        denmsk = ismember(evn_den, den);
        fevn = evn(denmsk);
        fevn_idc = evn_idc(denmsk);
        frtm = rtm(denmsk);

        event_prep(ses_EEG, fevn_idc, frtm, cat_pth, den);
    end
    
    sig_chans = {EEG.chanlocs.labels}';

    handles = {};
    axiis = {};
    cd(cat_pth)
    for ii = 1:length(sig_chans)
        chan_mats_struc = dir(['*' sig_chans{ii} '*']);
        channel_mats = {chan_mats_struc.name};
        axii = plot_naming_density(EEG, channel_mats, sig_chans{ii}, pth, ii, study);

        handles{ii} = get(axii, 'children');
        axiis{ii} = axii;
    end

    %subplot_all(handles, axiis, 4, [lock_pth 'Channel FBA Plots by Category/' study '/Group ' num2str(gsize) '/'])
    
end



