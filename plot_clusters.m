function mean_cluster = plot_clusters(cdat, lock, band, fs, cnum)

    switch lock
        case 'resp'
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
        case 'stim'
            begin_tm = -1000;
            st_tm = -500;
            en_tm = 1600;
    end
    
    T = get_lock_times(lock);

    if strcmp(band, 'HFB')
        fc = 15;
        [bb,aa] = butter(6,fc/(fs/2));
    end
    
    c = [.55,.55,.55];

%     figure('visible', 'off')
    figure
    set(gcf, 'Units','pixels','Position',[100 100 800 600])
    hold on

    minplot = 0;
    maxplot = 0;

    for k = 1:size(cdat,2)    

        if strcmp(band, 'HFB')
            dat = filtfilt(bb,aa,cdat(:,k));
        else
            dat = cdat(:,k);
        end

        mindat = min(dat);
        maxdat = max(dat);
        if mindat < minplot
            minplot = mindat;
        end
        if maxdat > maxplot
            maxplot = maxdat;
        end

%         tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
        tmesh = T.st:1000/fs:T.en;
%         datd = dat(tsamp);

        plot(tmesh, dat, 'color', c);

    end

    if strcmp(band, 'HFB')
        mean_cluster = filtfilt(bb,aa,mean(cdat,2));
    else
        mean_cluster = mean(cdat,2);
    end
        
    
    plot(tmesh, mean_cluster, 'k', 'Linewidth', 1.5);

    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 1, 'Color', 'k');
    plot([T.st T.en], [0 0],'k','LineWidth',1);

    title(sprintf('Cluster %i', cnum))
    xlim([T.st T.en])
    ylim([minplot-10 maxplot+10])
    xlabel('Time (ms)');
    ylabel('Change from Baseline (%)');

%     ap_fname = sprintf('%s/%s_%s_%s_%s.png', ap_pth, subj, band, ch_lab, ref);
%     saveas(gca, ap_fname)


   

end