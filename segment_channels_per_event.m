function segment_channels_per_event(EEG, TvD, pth, foc_nm, filter_data)

    subj = strsplit(EEG.setname,'_');
    subj = subj{1};
    fs = EEG.srate;
    band = EEG.band;
    evn = {EEG.analysis.type}';
    
    T = get_lock_times(EEG);
    
    tot_t = T.an_en - T.an_st;
    
    an_st = T.lidc + floor(T.an_st./1000 *fs) + 1; % Idx of lock + (-) analysis window st time
    an_en = T.lidc + floor(T.an_en./1000 *fs); % Idx of lock +  analysis window end time

    lab = {EEG.chanlocs.labels}';
    dat = double([EEG.data]);
    
    % trim non-significant data from data matrix
    if strcmp(band, 'NONE') || isempty(TvD)
        sig_lab = {EEG.chanlocs.labels}';
    else
        sig_lab = TvD(:,2);
        ismsk = ~ismember(lab,sig_lab);
        dat(ismsk,:) = [];
    end
    
    for kk = 1:size(dat,1)
        if filter_data  
            [b,a] = get_filter(band, fs);
            diT = filtfilt(b, a, dat(kk,:));
            datT(kk,:) = diT - mean(diT);
        else
            datT(kk,:) = dat(kk,:);
        end
    end

    evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs), length(evn));
    for jj = 1:length(evn)  
        for kk = 1:size(dat,1)
              windatT = datT(kk,:);
              evn_seg(kk,:,jj) = windatT(an_st(jj):an_en(jj));
        end     
    end
    save(sprintf('%s/%s_%s_%s.mat', pth, foc_nm, subj, EEG.ref), 'evn_seg', 'evn', 'sig_lab');
end


