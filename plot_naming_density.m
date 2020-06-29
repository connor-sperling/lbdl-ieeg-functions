function ax = plot_naming_density(EEG, dat_files, ch_lab, lock_pth, cnum, study)

    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '~/Desktop/iEEG/Subjs';
    end
    
    
    dt = strsplit(datestr(datetime));
    dt = dt{1};
    
    sid = strsplit(EEG.setname, '_');
    subj = sid{1};  
    task = sid{2};
    
    fs = EEG.srate;
    resp = [EEG.event.resp]';
    band = EEG.band{end};
    
    ref = EEG.ref;
    lock = EEG.lock{end};
        
    
    ap_pth = sprintf('%s/plots/%s/%s/%s', subjs_dir, dt, study, lock);
    plt_pth = sprintf('%s/Channel Plots by Position in Category/%s', lock_pth, band);
    
    if ~exist(ap_pth, 'dir')
        mkdir(ap_pth)
    end
    
    if ~exist(plt_pth, 'dir')
        mkdir(plt_pth)
    elseif cnum == 1
        fp = dir(fullfile(plt_pth, '*.png'));
        plts = {fp.name};
        for p = 1:length(plts)
            delete([plt_pth plts{p}]);
        end
    end

    switch lock
        case 'Response Locked'
            lnm = 'RL';
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
            second_mrk = -mean(resp);
        case 'Stimulus Locked'
            lnm = 'SL';
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
            second_mrk = mean(resp);
    end
    
    figure('visible', 'off')
    set(gcf, 'Units','pixels','Position',[100 100 800 600])
    hold on
    
    
    
    minplot = 0;
    maxplot = 0;

    for ii = 1:length(dat_files)
        
        chan_fname = strsplit(dat_files{ii}, '_');
        den = chan_fname{1};
        switch den
            case 'HD'
                c = [0/255, 125/255, 63/255];
            case 'LD'
                c = [153/255, 153/255, 0/255];
        end
    
        C = load(dat_files{ii}, 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;

%         dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
        fc = 10;
        [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
        dat = filter(bb,aa,mean(chnl_evnt,1));
        
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
        
        X(:,ii) = plot(tmesh, datd, 'color', c, 'Linewidth', 2, 'DisplayName', den);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 1, 'Color', 'k');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    if second_mrk > en_tm
        line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    elseif second_mrk < st_tm
        line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    else
        plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    end

    
    title(sprintf('Avg. %s by Density - %s - %s - %s - %s', band, subj, ch_lab, ref, lnm))
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
 
    plt_fname = sprintf('%s/%s_%s_%s.png', plt_pth, subj, ch_lab, ref);
    saveas(gca, plt_fname)
    
    ap_fname = sprintf('%s/%s_%s_%s.png', ap_pth, subj, ch_lab, ref);
    saveas(gca, ap_fname)
    
    ax = gca;
    ax.Title.String = ch_lab;
end