function plot_conditions_marseille(dat_files, ch_lab, subj, lock, band, cmat)
    
    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_Marseille/Subjs';
    end
   
    
    ap_pth = sprintf('%s/plots/GEN/%s', subjs_dir, lock);

    switch lock
        case 'resp'
            lnm = 'RL';
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
        case 'stim'
            lnm = 'SL';
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
    end
    
    fs = 1000;
    figure('visible', 'off')
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

        if strcmp(band, 'HFB')
%             dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
            fc = 15;
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
        
        tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
        tmesh = st_tm:1000/fs:en_tm;
        datd = dat(tsamp);
        
        X(:,ii) = plot(tmesh, datd, 'color', c, 'Linewidth', 2, 'DisplayName', foc_nm);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 1, 'Color', 'k');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    
    
    title(sprintf('Avg. %s Activity - %s - %s - %s', band, subj, ch_lab, lnm))
    xlim([st_tm en_tm])
    ylim([minplot-10 maxplot+10])
    xlab = xlabel('Time (ms)');
    ylab = ylabel('Change from Baseline (%)');
    set([xlab ylab], 'FontName', 'AvantGarde')
    set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
        'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
        'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0:10:maxplot+10, ...
        'LineWidth', 1)
    
    legend(X, 'Location', 'northwest')
    
    ap_fname = sprintf('%s/%s_%s_%s.png', ap_pth, subj, band, ch_lab);
    saveas(gca, ap_fname)
    
    ax = gca;
    ax.Title.String = ch_lab;
    close
end