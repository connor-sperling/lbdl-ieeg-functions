function stim_segmentation(EEG, TvD, pth, foc_nm)

    evn = {EEG.analysis.type}';
    evn_idc = [EEG.analysis.latency]';
    rtm = [EEG.analysis.resp]';
    if iscell(rtm)
        rtm = cellfun(@(x) str2double(x), rtm);
    end
    
    fs = EEG.srate; 
    lock = EEG.lock{end};
    band = EEG.band{end};
    rsp_idc = round(abs(rtm)./1000 *fs); % abs of rtm because incorrect reponses identified with a negative response time
    
    switch lock 
        case 'Response Locked'
            t_st = -650;
            t_en = 150;
%             t_bl_st = -1250;
%             t_bl_en = -750;
            lidc = evn_idc + rsp_idc;
        case 'Stimulus Locked'           
            t_st = 0;
            t_en = 800;
%             t_bl_st = -500;
%             t_bl_en = 0;
            lidc = evn_idc;
    end
    
    tot_t = t_en - t_st;
    
    an_st = lidc + floor(t_st./1000 *fs); % Idx of lock + (-) analysis window st time
    an_en = lidc + floor(t_en./1000 *fs); % Idx of lock +  analysis window end time

    labs = {EEG.chanlocs.labels}';
    dat = [EEG.data];
    
    slabs = TvD(:,2);
    ismsk = ~ismember(labs,slabs);
    dat(ismsk,:) = [];
    
    
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};

    evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs)+1);
    
    for kk = 1:size(dat,1)        
        if strcmp(band, 'HFB') 
            dat_bp = bandpass(dat(kk,:), [70, 150], fs);
            datT(kk,:) = dat_bp;
        elseif strcmp(band, 'LFP')
            [b,a] = butter(4, 30/(fs/2), 'low');
            datT(kk,:) = filtfilt(b,a,dat(kk,:));
        else
            datT(kk,:) = dat(kk,:);
        end
    

        chnl_evnt = zeros(length(lidc), round(tot_t/1000 *fs)+1);

        windatT = datT(kk,:);
        for jj = 1:length(lidc)
              % Raw event segment
              chnl_evnt(jj,:) = windatT(an_st(jj):an_en(jj));
        end  
        evn_seg(kk,:) = mean(chnl_evnt,1);
        
    end
    
    save(sprintf('%s/%s_%s_%s.mat', pth, foc_nm, pt_nm, EEG.ref), 'evn_seg');

    for kk = 1:length(lidc)  
        evn_seg = zeros(size(dat,1), round(tot_t/1000 *fs)+1);
        for jj = 1:size(dat,1)
              windatT = datT(jj,:);

              % Raw event segment
              evn_seg(jj,:) = windatT(an_st(kk):an_en(kk));
        end     

        save(sprintf('%s/%s_%s_%s_%s.mat', pth, foc_nm, pt_nm, EEG.ref, evn{kk}), 'evn_seg');
    end
end