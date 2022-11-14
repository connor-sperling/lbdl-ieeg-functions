function plot_connected_electrodes(subjs_dir, direc_dir, study, plt_study, adj_type, fs, ref, c)

    
    C = readtable(sprintf('%s/connections/%s/connections_%s.xlsx',direc_dir,study,adj_type));
    ord_plt_dir = sprintf('%s/connections/%s/All_%s_ordered',direc_dir,study,adj_type);
    my_mkdir(ord_plt_dir, 'rmdir')
    for n = 1:size(C,1)
        
        subj = C.Subj{n};
        lock = C.Lock{n};
        band = C.Band{n};
        cond = C.Condition{n};
        r_chan = C.R_Channel{n};
        c_chan = C.C_Channel{n};
        r_region = C.R_Region{n};
        c_region = C.C_Region{n};
        w = C.Weight(n);
        th = C.Threshold(n);
        mnzw = C.MNzW(n);
        
        dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s',subjs_dir,subj,plt_study,ref,lock,band);
        plt_dir = sprintf('%s/connections/%s/%s_%s/%s_%s',direc_dir,study,adj_type,cond,r_region,c_region);
        
        r_mat = sprintf('%s/%s_%s_%s_%s.mat',dat_dir,cond,subj,r_chan,ref);
        c_mat = sprintf('%s/%s_%s_%s_%s.mat',dat_dir,cond,subj,c_chan,ref);
        
        rD = load(r_mat, 'chnl_evnt');
        chnl_evnt_r = rD.chnl_evnt;
        
        cD = load(c_mat, 'chnl_evnt');
        chnl_evnt_c = cD.chnl_evnt;
        
        T = get_lock_times(lock);

        figure('visible', 'off')
        set(gcf, 'Units','pixels','Position',[100 100 800 600])
        hold on

%         dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
        if strcmp(band, 'HFB')
            fc = 14;
            [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
            dat_r = filter(bb,aa,mean(chnl_evnt_r,1));
            dat_c = filter(bb,aa,mean(chnl_evnt_c,1));
        else
            dat_r = mean(chnl_evnt_r,1);
            dat_c = mean(chnl_evnt_c,1);
        end
        
        mindat = min([dat_r dat_c]);
        maxdat = max([dat_r dat_c]);

        tsamp = floor((T.st-T.st)*fs/1000)+1:floor((T.en-T.st)*fs/1000)+1;
        tmesh = T.st:1000/fs:T.en;

        X(:,1) = plot(tmesh, dat_r(tsamp), 'color', c(1,:), 'Linewidth', 2, 'DisplayName', r_region);
        X(:,2) = plot(tmesh, dat_c(tsamp), 'color', c(2,:), 'Linewidth', 2, 'DisplayName', c_region);

        plot([0 0] ,[mindat-20 maxdat+20], 'LineWidth', 1, 'Color', 'k');
        plot([T.st T.en], [0 0],'k','LineWidth',1);
        

        title(sprintf('%s %s %s | %s | %s - %s (%s - %s) | w = %.3f (MNzW = %.3f)',subj,T.lock_abv,band,cond,r_region,c_region,r_chan,c_chan,w,mnzw))
        xlim([T.st T.en])
        ylim([mindat-10 maxdat+10])
        xlab = xlabel('Time (ms)');
        ylab = ylabel('Change from Baseline (%)');
        set([xlab ylab], 'FontName', 'AvantGarde')
        set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
            'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', ...
            'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3], 'YTick', 0:10:maxdat+10, ...
            'LineWidth', 1)

        legend(X, 'Location', 'northwest')

        plt_fname = sprintf('%s/%s_%s_%s_%s_%s-%s_%s-%s.png',plt_dir,subj,ref,lock,band,r_region,c_region,r_chan,c_chan);
        ord_plt_fname = sprintf('%s/%i-%s_%s_%s_%s_%s-%s_%s.png',ord_plt_dir,n,subj,ref,lock,band,r_region,c_region,cond);
        saveas(gca, plt_fname)
        saveas(gca, ord_plt_fname)
        close
    end
end




