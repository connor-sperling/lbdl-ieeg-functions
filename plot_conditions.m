function plot_conditions(EEG, dat_files, ch_lab, study, cmat)

    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs';
    end
   
    
    sid = strsplit(EEG.setname, '_');
    subj = sid{1};      
    fs = EEG.srate;
    band = EEG.band;
    
    ref = EEG.ref;
    lock = EEG.lock;   
    
    ap_pth = sprintf('%s/plots/%s/%s', subjs_dir, study, lock);
    
    T = get_lock_times(EEG);
    
    figure('visible', 'on')
    set(gcf, 'Units','pixels','Position',[100 100 800 600])
    hold on
    
    minplot = 0;
    maxplot = 0;

    for ii = 1:length(dat_files)
        
        chan_fname = strsplit(dat_files{ii}, '_');
        foc_nm = chan_fname{1};

        c = cmat(ii,:);
    
        C = load(dat_files{ii}, 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;

%         dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
        if strcmp(band, 'HFB')
            fc = 14;
            [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
            dat = filter(bb,aa,mean(chnl_evnt,1));
        else
            dat = mean(chnl_evnt,1);
        end
        mindat = min(dat);
        maxdat = max(dat);
        if mindat < minplot
            minplot = mindat;
        end
        if maxdat > maxplot
            maxplot = maxdat;
        end
        
        tsamp = floor((T.st-T.st)*fs/1000)+1:floor((T.en-T.st)*fs/1000)+1;
        tmesh = T.st:1000/fs:T.en;
        datd = dat(tsamp);
        
        X(:,ii) = plot(tmesh, datd, 'color', c, 'Linewidth', 2, 'DisplayName', foc_nm);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 1, 'Color', 'k');
    plot([T.st T.en], [0 0],'k','LineWidth',1);
    if T.scnd_mrk > T.en
        line([T.en T.en], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    elseif T.scnd_mrk < T.st
        line([T.st T.st], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    else
        plot([T.scnd_mrk T.scnd_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    end

    
    title(sprintf('Avg. %s Activity - %s - %s - %s - %s', band, subj, ch_lab, ref, lock))
    xlim([T.st T.en])
    ylim([minplot-10 maxplot+10])
    xlab = xlabel('Time (ms)');
    ylab = ylabel('Change from Baseline (%)');
    set([xlab ylab], 'FontName', 'AvantGarde')
    set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
        'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0:10:maxplot+10, ...
        'LineWidth', 1)
    
    legend(X, 'Location', 'northwest')
    
    ap_fname = sprintf('%s/%s_%s_%s_%s.png', ap_pth, subj, band, ch_lab, ref);
    saveas(gca, ap_fname)
    
    ax = gca;
    ax.Title.String = ch_lab;
    close
end