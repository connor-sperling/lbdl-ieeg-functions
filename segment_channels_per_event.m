function segment_channels_per_event(EEG, TvD, pth, foc_nm)

    
   
    subj = strsplit(EEG.setname,'_');
    subj = subj{1};
    fs = EEG.srate;
    band = EEG.band;
    evn = {EEG.analysis.type}';
    
    T = get_lock_times(EEG);
    
    tot_t = T.en - T.st;
    
    an_st = T.lidc + floor(T.st./1000 *fs); % Idx of lock + (-) analysis window st time
    an_en = T.lidc + floor(T.en./1000 *fs); % Idx of lock +  analysis window end time

    lab = {EEG.chanlocs.labels}';
    dat = double([EEG.data]);
    
    % trim non-significant data from data matrix
    sig_lab = TvD(:,2);
    ismsk = ~ismember(lab,sig_lab);
    dat(ismsk,:) = [];
    
    evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs)+1);
    
    for kk = 1:size(dat,1)        
        if strcmp(band, 'HFB') 
            Wp = [70 150]/(fs/2);
            Ws = [60 160]/(fs/2);
            Rp = 3;
            Rs = 40;
            [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
            [b,a] = cheby2(n,Rs,Ws);
            datT(kk,:) = filtfilt(b, a, dat(kk,:));
%             dat_bp = bandpass(dat(kk,:), [70, 150], fs);
%             datT(kk,:) = dat_bp;
        elseif strcmp(band, 'LFP')
            Wp = 30/(fs/2);
            Ws = 45/(fs/2);
            Rp = 3;
            Rs = 40;
            [n,~] = buttord(Wp,Ws,Rp,Rs);
            [b,a] = butter(n, Wp, 'low');
            datT(kk,:) = filtfilt(b,a,dat(kk,:));
        else
            datT(kk,:) = dat(kk,:);
        end
    

        chnl_evnt = zeros(length(T.lidc), round(tot_t/1000 *fs)+1);

        windatT = datT(kk,:);
        for jj = 1:length(T.lidc)
              % Raw event segment
              chnl_evnt(jj,:) = windatT(an_st(jj):an_en(jj));
        end  
        evn_seg(kk,:) = mean(chnl_evnt,1);
        
    end
    
    save(sprintf('%s/%s_%s_%s_mean.mat', pth, foc_nm, subj, EEG.ref), 'evn_seg', 'sig_lab');

    for kk = 1:length(T.lidc)  
        evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs)+1);
        for jj = 1:size(dat,1)
              windatT = datT(jj,:);

              % Raw event segment
              evn_seg(jj,:) = windatT(an_st(kk):an_en(kk));
        end     

        save(sprintf('%s/%s_%s_%s_%s.mat', pth, foc_nm, subj, EEG.ref, evn{kk}), 'evn_seg', 'sig_lab');
    end
end