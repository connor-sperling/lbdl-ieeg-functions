function T = get_lock_times(S)

    if ischar(S)
        lock = S;
        rtm = [];
        rtmi = [];
        evni = [];
    else
        lock = S.lock;
        rtm = [S.analysis.resp]';
        rtmi = round(rtm./1000 *S.srate);
        evni = [S.analysis.latency]';
    end

    T = struct;
    switch lock
        case 'resp'        
            T.st = -1250; % window start time w.r.t response onset
            T.en = 750; % window end time w.r.t response onset
            T.an_st = -750; % time analysis begins w.r.t response onset
            T.an_en = 750; % time analysis ends w.r.t response onset
            T.bl_st = -1250; % baseline start time w.r.t response onset
            T.bl_en = -750;
            T.scnd_mrk = -mean(rtm); % average stimulus onset
            T.lidc = evni + rtmi; % lock index
        case 'stim'
            T.st = -500;
            T.en = 1600;
            T.an_st = 0;
            T.an_en = 1000;
            T.bl_st = -500;
            T.bl_en = 0;
            T.scnd_mrk = mean(rtm); % average response onset
            T.lidc = evni;
    end

end