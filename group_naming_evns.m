function group_naming_evns(EEG, keyset, gsize, cln_evn_typ, cln_evns, cln_resp, lock_pth)

    task = EEG.info.task;
    study = EEG.info.study;
    ref = EEG.info.ref;
    lock = EEG.info.lock;
    
    k = 1;
    while k <= length(keyset)  

        if gsize > 1
            catn = [keyset{k} '-' num2str(k+gsize-1)];
        else
            catn = keyset{k};
        end

        foc_nm = ['poscat' catn];
        cat_pth = [lock_pth foc_nm '/' study '/'];
        if ~exist(cat_pth, 'dir')
            mkdir(cat_pth);
        end
            k = k + gsize;

        focus_evn_typ = {}; focus_evns = []; focus_resp = [];
        for ii = k:k+gsize-1
            temp_typ = cln_evn_typ(cellfun(@(x) contains(x, char(keyset(ii))), id));
            temp_evns = cln_evns(ismember(cln_evn_typ, temp_typ));
            temp_resp = cln_resp(ismember(cln_evn_typ, temp_typ));

            focus_evn_typ = [focus_evn_typ; temp_typ];
            focus_evns = [focus_evns; temp_evns];
            focus_resp = [focus_resp; temp_resp];
        end
        % gather sig channel data over specific events & filter
        event_prep(EEG, focus_evns, focus_evn_typ, focus_resp, lock, study, cat_pth, ref, foc_nm);

        cd(cat_pth)
        foc_mats = dir('*.mat');
        foc_mats = {foc_mats.name};
        sig_flds = {};

        for ii = 1:length(foc_mats)
            sigchan = strsplit(foc_mats{ii}, '_');
            sigchan = sigchan{3};
            sigchan_fld = {['channel_' sigchan '/']};
            sig_flds = [sig_flds sigchan_fld];

            if ~exist([lock_pth char(sigchan_fld)], 'dir')
                mkdir([lock_pth char(sigchan_fld)])
            end

            copyfile(foc_mats{ii}, [lock_pth 'channel_' sigchan '/' foc_mats{ii}]);
        end

    end
end