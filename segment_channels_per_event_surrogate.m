function [evn_seg, evn] = segment_channels_per_event_surrogate(EEG, sig_lab, study, shift)

    T = get_lock_times(EEG);
    tot_t = T.an_en - T.an_st;

    lab = {EEG.chanlocs.labels}';
    dat = double([EEG.data]);
    
    evn = {EEG.analysis.type}';

    if ~isempty(sig_lab)
        ismsk = ~ismember(lab,sig_lab);
        dat(ismsk,:) = [];
    end
    
    fs = EEG.srate;
    band = EEG.band;

    an_st = -shift + T.lidc + floor(T.an_st./1000 *fs) + 1; % Idx of lock + (-) analysis window st time
    an_en = -shift + T.lidc + floor(T.an_en./1000 *fs); % Idx of lock +  analysis window end time

    if strcmp(study, 'Stroop_CIC-CM')
        [b,a] = get_filter(band, fs);
    end

    for kk = 1:size(dat,1)
        if strcmp(study, 'Stroop_CIC-CM')
            diT = filtfilt(b, a, dat(kk,:));
            datT(kk,:) = diT - mean(diT);
        else
            datT(kk,:) = dat(kk,:);
        end
    end

    evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs), length(T.lidc));
    for jj = 1:length(T.lidc)  
        for kk = 1:size(dat,1)
            windatT = datT(kk,:);
            evn_seg(kk,:,jj) = windatT(an_st(jj):an_en(jj));
        end     
    end
        
    
end
