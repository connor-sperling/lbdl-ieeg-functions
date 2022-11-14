function txt4r(EEG, TvD, win_ms, subjs_dir, dat_pth, study)
    
    stinf = strsplit(EEG.setname, '_');
    subj = stinf{1};
    task = stinf{2};
    ref = EEG.ref;
    band = EEG.band;
    lock = EEG.lock;
    fs = EEG.srate;
    
    T = get_lock_times(EEG);

    mat_st = T.an_st - T.st;
    mat_en = T.an_en - T.st;  
    
    tot_t = mat_en - mat_st;
        
    [win_ms, xdiv] = dividewindow(tot_t, win_ms, 100);
    
    dfiles = dir(sprintf('%s/*.mat', dat_pth));
    dfiles = {dfiles.name};
    fnsplt = cellfun(@(x) strsplit(x,'_'), dfiles, 'UniformOutput', false);
    focids = unique(cellfun(@(x) x{1}, fnsplt, 'UniformOutput', false));
    
    for f = 1:length(focids)
        
        foc_nm = focids{f};
    
        tname = sprintf('%s_%s_average_%s_activity_by_%dms_segments.txt', study, foc_nm, band, win_ms);
        txt_pth = sprintf('%s/txts', subjs_dir);
        fname = sprintf('%s/%s', txt_pth, tname);
        if ~exist(txt_pth, 'dir')
            mkdir(txt_pth);
        end


        z = zeros(xdiv, floor(win_ms*fs/1000));

        for x = 1:xdiv
            ztemp = floor((mat_st + (x-1)*win_ms + 1)*fs/1000):floor((mat_st + x*win_ms)*fs/1000);
            if length(ztemp)-size(z,2) == 1
                ztemp = ztemp(1:end-1);
            end
            z(x,:) = ztemp;
        end

%         evn_msk = ~ismember({EEG.event.type}', {EEG.analysis.type}');

    %     allregion = readtable(sprintf('%s/Excel Files/channel_region.xlsx', subjs_dir));
    %     subregion = allregion(cellfun(@(x) strcmp(x, subj), allregion.subject),:);


        patdata = readtable(sprintf('%s/%s/data/%s_CV_%s.xlsx', subjs_dir, subj, subj, task));
        header = patdata.Properties.VariableNames;
        formspec = '';
        for i = 1:length(header)
            formspec = [formspec ' %s'];
        end

        elecs = TvD(:,2);

        for ii = 1:length(elecs)


            lab = elecs{ii};
    %         reginf = shaftinf(cellfun(@(x) strcmp(x, lab), shaftinf.label),:);
    %         if ~isempty(reginf)
    %             region = char(reginf.region);
    %         else
    %             region = 'ud';
    %         end

            load(sprintf('%s/%s_%s_%s_%s.mat', dat_pth, foc_nm, subj, lab, ref), 'chnl_evnt', 'evn');
            
            evn_splt = cellfun(@(x) strsplit(x,'-'), evn, 'UniformOutput', false);
            evn_trial_nums = cellfun(@(x) str2double(x{1}), evn_splt);
            pd_trial_nums = table2array(patdata(:,cellfun(@(x) strcmpi(x,'trial_num'), header)));
            evn_msk = ismember(pd_trial_nums, evn_trial_nums);
            
            patdata_trim = patdata(evn_msk, :);
            
            writetable(patdata_trim, sprintf('%s/%s/data/%s_CV_%s.txt', subjs_dir, subj, subj, task), 'Delimiter', 'tab')
            fid = fopen(sprintf('%s/%s/data/%s_CV_%s.txt', subjs_dir, subj, subj, task));
            
            pred = textscan(fid,formspec);
            fclose(fid);

%             varmsk = cellfun(@(x) strcmpi(x{1}, 'trial_num'), pred);
%             vartemp = pred(varmsk);
%             pred(varmsk) = [];
%             pred = [vartemp pred];
% 
%             varmsk = cellfun(@(x) strcmpi(x{1}, 'patient'), pred);
%             vartemp = pred(varmsk);
%             pred(varmsk) = [];
%             pred = [vartemp pred];

            y = zeros(size(chnl_evnt,1), xdiv);

            sig_idcs = TvD{ii,5};

            for k = 1:size(z,1)
    %             if ~isempty(intersect(sig_idcs,z(k,:)))
    %                 w = z(k,:); 
    %                 y(:,k) = double(mean(chnl_evnt(:,w),2));
    %             end
                w = z(k,:); 
                y(:,k) = double(mean(chnl_evnt(:,w),2));
            end


            if ~exist(fname, 'file') 
                % Header
                fid = fopen(fname, 'wt');
                sublist = sprintf('%s\t%s\tEvent_Locked\tChannel\tSegment\tAvg_Data', pred{1}{1}, pred{2}{1});
                for i = 3:length(pred)
                    sublist = sprintf('%s\t%s', sublist, pred{i}{1}); 
                end
                fprintf(fid, '%s', sublist);
                fprintf(fid, '\n');
            else
                % File exists, append
                fid = fopen(fname, 'a');
            end

            for x = 1:xdiv
                for k = 1:size(y,1) 
                    sublist = sprintf('%s\t%s\t%s\t%s\t%d\t%f', pred{1}{k+1}, pred{2}{k+1}, lock, lab, x, y(k,x));
                    for l = 3:length(pred) 
                        sublist = sprintf('%s\t%s', sublist, pred{l}{k+1}); 
                    end
                    fprintf(fid, '%s', sublist);
                    fprintf(fid, '\n');
                end
            end

            fclose(fid); % Close the stats file


        end        
    end
end
