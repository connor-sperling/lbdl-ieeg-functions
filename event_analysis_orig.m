function event_analysis_orig(EEG, evns, evn_typ, restm, lock, study, pth, ref_typ, foc_nm)

    % MAKE SURE ALL PLOTS ARE CLOSED BEFORE EXECUTING %
    fs = EEG.srate; 
 
    switch lock 
    case 'Response Locked'
        start_time_window = -1500;
        tm_st  = round( start_time_window./1000 *fs);
        tm_en  = round( 500./1000 *fs);
        bl_st =  round( -1500./1000 *fs); % baseline
        bl_en =  round( -1000./1000 *fs); % baseline

    case 'Stimulus Locked'
        start_time_window = -1000;
        tm_st  = round( start_time_window./1000 *fs);
        tm_en  = round( 2000./1000 *fs);
        bl_st =  round( -1000./1000 *fs);
        bl_en =  round( -500./1000 *fs);
    end
    
    evn_tm = tm_st:tm_en;
    rtm_sam = round(restm./1000 *fs);
   
    evn_corr = evns(rtm_sam > 0) + rtm_sam(rtm_sam > 0);
    evn_wind_st = evn_corr + tm_st;
    evn_wind_en = evn_corr + tm_en;
    bl_wind_st  = evn_corr + bl_st;
    bl_wind_en  = evn_corr + bl_en;
    
    chnl_lbl = {EEG.chanlocs.labels};
    ch_Data = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    task = pt_id{2};

    for kk = 1:size(ch_Data,1)
        
        loadbar(kk, size(ch_Data,1))
        
        dat = ch_Data(kk,:);
        if strcmp(study, 'HG')
            datT(kk,:) = conv(abs(my_hilbert2(dat,fs,70,150,1,'HMFWgauss')),hann(50));
        elseif strcmp(study, 'LFP')
            % lowpass to isolate LFP
            [b,a] = butter(4, 30/(fs/2), 'low');
            datT(kk,:) = filtfilt(b,a,dat);

            % alternative to isolate the LFP and remove very low frequency components
%             [b,a] = butter(4, [0.1 30]/(fs/2), 'bandpass');
%             data = filtfilt(b,a,data);
        end
        
        band = datT(kk,:);
        chnl_evnt = [];

        for jj = 1:length(evn_corr)
            chnl_evnt(jj,:) = (band(evn_wind_st(jj):evn_wind_en(jj)) - mean(band(bl_wind_st(jj):bl_wind_en(jj))))./mean(band(bl_wind_st(jj):bl_wind_en(jj))) *100;
        end
        
        chan_fname = [foc_nm '_' pt_nm '_' chnl_lbl{kk} '_' ref_typ '.mat']; % File name for each electrode
        save([pth chan_fname], 'chnl_evnt', 'evn_tm');
        
%         
%         figure('visible', 'off')
%         plot(evn_wind,mean(chnl_evnt,1),'Linewidth',2);grid 
%         % mean(A,dim) where dim is the dimension over which we have taken
%         % the average same as mean(A)
%         title([pt_nm ' ' task ' task, Channel #' num2str(kk) ' - ' chnl_lbl{kk}])
%         plt_fname = [foc_nm '_' pt_nm '_' chnl_lbl{kk} '_' ref_typ '.jpeg'];
%         saveas(gca,[plot_path plt_fname])
%         
    end    
end