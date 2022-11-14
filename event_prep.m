function event_prep(EEG, evn, evni, rtm, pth, foc_nm)

% event_prep reads in data in Channel x Time format and reorganizes each
% of its rows (channels) into separate matricies (# events x Time). The
% time window around each of the events is 'locked' to either the stimulus
% onset or response onset of each event. A matrix is created and saved in 
% .mat format for each of the channels (# rows) in the input data.

    fs = EEG.srate; 
    lock = EEG.lock;
    band = EEG.band;
    rtmi = round(rtm./1000 *fs);
    
    switch lock 
        case 'resp'
            t_st = -1250; % time window start time w.r.t response onset
            t_en = 750; % time window end time w.r.t response onset
            t_bl_st = -1250; % baseline start time w.r.t response onset
            t_bl_en = -750; % baseline end time w.r.t response onset
            lidc = evni + rtmi; % lock index
        case 'stim'           
            t_st = -1000; % time window start time w.r.t stimulus onset
            t_en = 1600;
            t_bl_st = -500;
            t_bl_en = 0;
            lidc = evni;
    end
    
    tot_t = t_en - t_st; % Total time in event window
    bl_t = t_bl_en - t_bl_st; % Total time in baseline window
    
    an_st = lidc + floor(t_st./1000 *fs); % Idx of lock + (-) analysis window st time
    an_en = lidc + floor(t_en./1000 *fs); % Idx of lock +  analysis window end time
    bl_st  = lidc + floor(t_bl_st./1000 *fs); % Idx of lock + (-) baseline window st time
    bl_en  = lidc + floor(t_bl_en./1000 *fs); % Idx of lock + (-) baseline window end time
            
 
    labs = {EEG.chanlocs.labels}; % channel labels
    dat = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};

    for kk = 1:size(dat,1)        
        % isolate 'band' frequencies and recover the envelope of the signal
        if strcmp(band, 'HFB') 
            dat_bp = bandpass(dat(kk,:), [70, 150], fs); % Filtered data
            datT = abs(hilbert(dat_bp)); % Envelope of HFB signal
        elseif strcmp(band, 'LFP')
            [b,a] = butter(4, 30/(fs/2), 'low'); % Filter coefficients
%             [b,a] = butter(4, [0.1 30]/(fs/2), 'bandpass');
            datT = abs(hilbert(filtfilt(b,a,dat(kk,:)))); % Envelope of LFP signal
        else
            datT = abs(hilbert(dat(kk,:))); % Envelope of entire signal
        end
        
        chnl_evnt = zeros(length(lidc), round(tot_t/1000 *fs)+1); 
        bl_dat = zeros(length(lidc), round(bl_t/1000 *fs)+1);
        
        % Each iteratoon saves the data in the channel around the next
        % successive stimulus event while normalizing and subtracting by
        % the basline average. Signal around each event is transformed to
        % "percentage rise from baseline" through this process.
        for jj = 1:length(lidc)
            chnl_evnt(jj,:) = (datT(an_st(jj):an_en(jj)) - mean(datT(bl_st(jj):bl_en(jj))))./mean(datT(bl_st(jj):bl_en(jj))) *100;
            bl_dat(jj,:) = datT(bl_st(jj):bl_en(jj)) - mean(datT(bl_st(jj):bl_en(jj)));
        end     
        
        save(sprintf('%s/%s_%s_%s_%s.mat', pth, foc_nm, pt_nm, labs{kk}, EEG.ref), 'chnl_evnt', 'bl_dat', 'evn');

    end    
end