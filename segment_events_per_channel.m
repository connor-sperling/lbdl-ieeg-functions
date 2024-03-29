function segment_events_per_channel(EEG, pth, foc_nm)

% event_prep reads in data in Channel x Time format and reorganizes each
% of its rows (channels) into separate matricies (# events x Time). The
% time window around each of the events is 'locked' to either the stimulus
% onset or response onset of each event. A matrix is created and saved in 
% .mat format for each of the channels (# rows) in the input data.

    evn = {EEG.analysis.type}';
    fs = EEG.srate; 
    band = EEG.band;
    
    % returns struct (T) of time stamps for segmentation/analysis purposes
    T = get_lock_times(EEG); 
    
    tot_t = T.en - T.st; % Total time in event window
    bl_t = T.bl_en - T.bl_st; % Total time in baseline window
    
    win_st = T.lidc + floor(T.st./1000 *fs); % Idx of lock + (-) analysis window st time
    win_en = T.lidc + floor(T.en./1000 *fs); % Idx of lock +  analysis window end time
    an_st  = T.lidc + floor(T.an_st./1000 *fs); % Idx of lock + (-) baseline window st time
    an_en  = T.lidc + floor(T.an_en./1000 *fs); % Idx of lock + (-) baseline window end time
    bl_st  = T.lidc + floor(T.bl_st./1000 *fs); % Idx of lock + (-) baseline window st time
    bl_en  = T.lidc + floor(T.bl_en./1000 *fs); % Idx of lock + (-) baseline window end time
            
 
    labs = {EEG.chanlocs.labels}; % channel labels
    dat = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};

    for kk = 1:size(dat,1)        
        % isolate 'band' frequencies and recover the envelope of the signal
        if strcmp(band, 'HFB') || strcmp(band, 'LFP')
            [b,a] = get_filter(band, fs); % get coeffs for chebyshev filter
            datT = filtfilt(b, a, double(dat(kk,:))); % zero phase-dist filter
            datT = datT - mean(datT);
            datT_evlp = abs(hilbert(datT)); % analytical amplitude of signal
        else
            datT = dat(kk,:); % Envelope of entire signal
            datT_evlp = abs(hilbert(datT));
        end
        
        chnl_evnt = zeros(length(T.lidc), round(tot_t/1000 *fs)+1); 
        chnl_data = zeros(length(T.lidc), round((T.an_en-T.an_st)/1000 *fs)+1); 
        bl_dat = zeros(length(T.lidc), round(bl_t/1000 *fs)+1);
        
        % Each iteration saves the data in the channel around the next
        % successive stimulus event while normalizing and subtracting by
        % the basline average. Signal around each event is transformed to
        % "percentage rise from baseline" through this process.
        for jj = 1:length(T.lidc)
            chnl_evnt(jj,:) = (datT_evlp(win_st(jj):win_en(jj)) - mean(datT_evlp(bl_st(jj):bl_en(jj))))./mean(datT_evlp(bl_st(jj):bl_en(jj))) *100;
            chnl_data(jj,:) = datT(an_st(jj):an_en(jj));
            bl_dat(jj,:) = datT(bl_st(jj):bl_en(jj));
        end     
        
        save(sprintf('%s/%s_%s_%s_%s.mat', pth, foc_nm, pt_nm, labs{kk}, EEG.ref), 'chnl_evnt', 'chnl_data', 'bl_dat', 'evn');

    end    
end