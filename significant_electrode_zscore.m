function TvD = significant_electrode_zscore(EEG, pth, foc_nm)

    pt_id = strsplit(EEG.setname, '_');
    subj = pt_id{1};
    lab = {EEG.chanlocs.labels};
    fs = EEG.srate;
    band = EEG.band;
    
    
    % set paths
    mat_pth = sprintf('%s/data/%s', pth, band);
    plot_pth = sprintf('%s/plots/%s', pth, band);
    tvd_pth = sprintf('%s/TvD/%s', pth, band);

    % time in milliseconds
    T = get_lock_times(EEG);
    
    % convert to samples
    an_st = round(abs(T.an_st-T.st)*fs/1000)+1;
    an_en = round(abs(T.an_en-T.st)*fs/1000);    
    bl_st = round(abs(T.bl_st-T.st)*fs/1000)+1;
    bl_en = round(abs(T.bl_en-T.st)*fs/1000)+1;
    
    q = 0.05;
    TvD = cell(0,5);
    k = 0;
    an_time = an_en-an_st+1;
    
    for ii = 1:length(lab)

        load(sprintf('%s/%s_%s_%s_%s.mat', mat_pth, foc_nm, subj, lab{ii}, EEG.ref), 'chnl_evnt');
        
        bl_dat = chnl_evnt(:,bl_st:bl_en); % baseline data
        dat = chnl_evnt(:,an_st:an_en); % data for analysis
        
        mbl = mean(mean(bl_dat)); % mean of the baseline sample means
        sbl = mean(std(bl_dat)); % mean of the baseline sample st. devs

        H = zeros(an_time, 1);
        P = H;
        for n = 1:an_time
            [h,p] = ztest(dat(:,n),mbl,sbl,'Tail','right');
            H(n) = h; % h=0 -> fail to reject Ho, h=1 -> reject Ho
            P(n) = p; % p-value
        end
        
        % correct for multiple comparisons
        [pthr, ~, padj] = fdr2(P,q); % false detection rate
        hcorr = P < pthr;
        
        % require significant data to be >= 10% above baseline
        hcorr = (mean(dat,1)'>=10) & hcorr;
        
        % find lengths of continuous significance regions
        offset_idc = find(diff([hcorr; 0]) == -1);
        onset_idc = find(diff([0; hcorr]) == 1);
        chunk_lens = offset_idc - onset_idc + 1;
        
        % filter out significance regions that are not 100ms long
        sig_chunk_msk = chunk_lens >= 100;
        sig_offset = offset_idc(sig_chunk_msk); % onset of significance
        sig_onset = onset_idc(sig_chunk_msk); % offset of significance

        % if a channel is found to have a significant region, make new row
        % in TvD
        if sum(sig_chunk_msk) > 0
            k = k + 1;
            TvD{k,1} = ii;
            TvD{k,2} = lab{ii};
            TvD{k,3} = pthr; %corrected pvalue threshold
            TvD{k,4} = P; %original pvalues
            TvD{k,5} = [sig_onset sig_offset];
            TvD{k,6} = padj; %adjusted pvalues
        end
    end

    save(sprintf('%s/%s_%s_TvD.mat', tvd_pth, foc_nm, band), 'TvD');
    
    sig_chans = TvD(:,2);
    
    fc = 15;
    [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
    
    % plot significant electrodes
    for ii = 1:length(sig_chans)
        load(sprintf('%s/%s_%s_%s_%s.mat', mat_pth, foc_nm, subj, sig_chans{ii}, EEG.ref), 'chnl_evnt');
        samp_sd = std(chnl_evnt)/sqrt(size(chnl_evnt,1));
        if strcmp(band, 'HFB')
            dat = filtfilt(bb,aa,mean(chnl_evnt,1));
        else
            dat = mean(chnl_evnt,1);
        end
        plot_significant_electrode(dat, sig_chans{ii}, samp_sd, TvD{ii,5}, EEG, plot_pth, foc_nm)
    end
    
end
