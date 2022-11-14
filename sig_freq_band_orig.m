function sig_freq_band_orig(EEG, lock_typ, pth, study, task, ref_typ, foc_nm)

    
    warning('off')
    srate = EEG.srate;
    
    mat_pth = [pth 'Channel events/' study '/'];
    plot_pth = [pth 'plots/' study ' fba/'];
    fig_pth = [pth 'figs/' study ' fba/'];
    tvd_pth = [pth 'TvD/'];

    switch lock_typ
    case 's' % RESPONSE WAS HERE
        st_tp = round((750*srate)/1000);
        en_tp = round((1750*srate)/1000);
    case 'r' % STIMULUS WAS HERE
        st_tp = round((1000*srate)/1000);
        en_tp = round((3000*srate)/1000);
    end

    
    evn_period = st_tp+1:en_tp;
    len_window = round((100*srate)/1000);
    nwin = floor(size(evn_period,2)/len_window);
    window_block = zeros(nwin,len_window);
    x = 1;
    for w = 1:nwin
        window_block(w,:) = evn_period(x):evn_period(x+(len_window-1));
        x = x + len_window;
    end
    
    chunksize = 100/1000*srate; % 100ms * fs
    q = 0.05;

    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    task = pt_id{2};

        
    mats = dir(mat_pth);
    mats = {mats.name};
    mats = mats(~cellfun('isempty',strfind(mats,'.mat')));
    

    %calculate difference between target and decision per electrode using unpaired ttest for every time point

    sig_msk = [];
    if exist('TvD', 'var')
        clear TvD
    end
    TvD = {};
    k = 0;
    disp('  ')
    disp('  Building TvD')
    disp(' --------------')
    for ii = 1:length(mats)
        
        loadbar(ii, length(mats));
        
        k = k + 1;
        load([mat_pth mats{ii}], 'chnl_evnt');

        pvals = [];
        hvals = [];
        
        % unpaired ttest at every point
        for N = 1:nwin
            winN = window_block(N, :);
            zmean_pop = single(zeros(size(chnl_evnt(:,1))));
            event_popm = mean(chnl_evnt(:,winN),2);
            [h, p] = ttest2(zmean_pop, event_popm, 'Alpha', q, 'Tail', 'right', 'Vartype', 'unequal');

            pvals = [pvals p];
            hvals = [hvals h];
        end
        
        %fdr correct
        [pthr, pcor, padj] = fdr2(pvals,q);

        %find starting indicies of significance groups
        H = pvals < pthr;

        %identify if electrode is significant (has significant chunk that is >10% baseline)
        difference = diff(H);
        start_idx = window_block(find(difference == 1),1) + 1;
        end_idx = window_block(find(difference == -1),len_window);
        
        if numel(start_idx)>numel(end_idx) %the last chunk goes until the end
            end_idx = [end_idx;window_block(nwin,len_window)];
        elseif numel(start_idx)<numel(end_idx) %starts immediate significant
            start_idx = [st_tp;start_idx]; 
        end
        
        if ~isempty(start_idx) && (start_idx(1) > end_idx(1)) % starts immediately significant
            start_idx = [st_tp;start_idx];
        end
        if ~isempty(start_idx) && (end_idx(end) < start_idx(end)) %there is no end_idx - significant until end
            end_idx = [end_idx;window_block(nwin,len_window)];
        end
        
        chunks = (end_idx-start_idx) >= chunksize;
        if sum(chunks)==0
            sig_msk = [sig_msk 0];

        elseif ~isempty(start_idx)
            chunks = ((end_idx-start_idx)>=chunksize);
            if sum(chunks)>0 %at least 1 chunk is > chunksize (ex 50ms)
                TvD{k,1} = k;
                TvD{k,2} = char(erase(mats{ii}, [foc_nm, ".mat", string(pt_nm), string(ref_typ), string(task), "_"]));
                TvD{k,3} = pthr; %corrected pvalue threshold
                TvD{k,4} = pvals; %original pvalues
                TvD{k,5} = [start_idx(chunks) end_idx(chunks)];
                TvD{k,6} = padj; %adjusted pvalues
            end
            start_idx = start_idx(chunks); 
            end_idx = end_idx(chunks);

            sig_msk = [sig_msk 1];
        end
    end
    
    % remove empty rows in TvD
    emptyCells = cellfun('isempty', TvD);
    TvD(all(emptyCells,2),:) = [];
    
    % Save TvD to focus type TvD folder
    save([tvd_pth study '_TvD.mat'],'TvD');

    
    
    % plot significant electrodes
    stim = 0/1000*srate;
    ticks_tp = round(250./1000*srate); %plotting

    switch lock_typ
    case 's' % RESPONSE WAS HERE            
        start_time_window = -1500;
        tm_st  = round( start_time_window ./1000*srate);
        tm_en  = round( 500 ./1000*srate);
        st_new = -750;
        en_new = round( 250 ./1000*srate);
    case 'r' % STIMULUS WAS HERE
        start_time_window = -1000;
        tm_st  = round( start_time_window ./1000*srate);
        tm_en  = round( 2000 ./1000*srate);
        st_new = 0;
        en_new = round( 1000 ./1000*srate);
    end

    hfb_mats = mats(logical(sig_msk));
    plot_jump = 500;
    jm = round(plot_jump./1000*srate);
    k = 0;
    
    disp('  ')
    disp(['  Plotting ' study])
    disp(' --------------')
    for ii = 1:length(hfb_mats)
        
        loadbar(ii, length(hfb_mats))
        
        k = k + 1;
        chan_lab = char(erase(hfb_mats{ii}, [foc_nm, ".mat", string(pt_nm), string(ref_typ), string(task), "_"]));

%         msg = sprintf('Channel: %s\n', chan_lab);
%         disp(msg)
        
        load([mat_pth hfb_mats{ii}], 'chnl_evnt');
        semT = squeeze(std(chnl_evnt(:,:))/sqrt(size(chnl_evnt,1)))';
        scalemax = max(max(squeeze(mean(chnl_evnt(:,:)))+semT'));
        scalemin = min(min(squeeze(mean(chnl_evnt(:,:)))-semT'));
        
        
        
        f1 = figure('visible', 'off','color','white');
        ax1 = axes;
        f2 = figure('visible', 'off','color','white');
        ax2 = axes;
        set(f1, 'Units','pixels','Position',[100 100 800 600])

        if scalemin > 0
            scalemin = -10;
        end
        %vectors are not the same length. 'y' should be a 1x2001
        %vector. Something to do with diffence on line 111-112?
        h = shade_plot(tm_st:tm_en, squeeze(mean(chnl_evnt)), semT',rgb('steelblue'),0.5,1); hold on
        for z = 1:length((tm_st:jm:tm_en))
            plot_str{z} = start_time_window + (z-1)*plot_jump; 
        end
        set(ax1,'XTick',(tm_st:jm:tm_en),'XTickLabel',plot_str,'XTickMode','manual','Layer','top');
        xlim(ax1,[tm_st tm_en])
    
        warning('off')
        plot(ax1,[stim stim] ,[scalemin scalemax], '--','LineWidth',2, 'Color',rgb('SlateGray')); hold on;
        xlabel('ms'); ylabel('% change from baseline');
        plot(ax1,[tm_st tm_en], [0 0],'k','LineWidth',1); hold on
        plot(ax1,[st_new tm_en], [0 0],'k','LineWidth',3);
        start_idx = TvD{k,5}(:,1)+tm_st;
        end_idx = TvD{k,5}(:,2)+tm_st;

        for i = 1:length(start_idx)
            plot(ax1,(start_idx(i):end_idx(i)), zeros(1,length(start_idx(i):end_idx(i))), 'r', 'LineWidth',3); hold on
        end

        title(sprintf('%s - %s - one-sided - %s > zero for >%ims', pt_nm, chan_lab, task, chunksize/srate*1000))
        axis tight
        grid on
        
        print('-dpng',sprintf('%se_%s_%2.2f_%ims.png',plot_pth, chan_lab, q, chunksize))
        saveas(gcf, sprintf('%se_%s_%2.2f_%ims.fig',fig_pth, chan_lab, q, chunksize))
        close

    end
end
