function [evn_seg, evn] = segment_channels_per_event_BREAK(EEG, sig_lab, study, break_set, blacklist_set)

    fs = EEG.srate;
    band = EEG.band;
    
    T = get_lock_times(EEG);
    tot_t = T.an_en - T.an_st;
    tot_samp = floor(tot_t/1000 *fs);

    dat = double([EEG.data]);
    evn = {EEG.analysis.type}';
    
    population = [];
    for r = 1:size(break_set,1)
        population = [population; transpose(break_set(r,1):break_set(r,2))];
    end
    
    blacklist = [];
    for s = 1:size(blacklist_set,1)
        blacklist = [blacklist; transpose(blacklist_set(s,1):blacklist_set(s,2))];
    end
    
    population(ismember(population, blacklist)) = [];
    
    an_st = randsample(population, length(evn));
    an_en = an_st + tot_samp - 1;

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

    evn_seg = zeros(size(dat,1), floor(tot_t/1000 *fs), length(T.lidc));
    for jj = 1:length(T.lidc)  
        for kk = 1:size(dat,1)
            windatT = datT(kk,:);
            evn_seg(kk,:,jj) = windatT(an_st(jj):an_en(jj));
        end     
    end
        
    
end
