function plot_significant_electrode(dat, lab, samp_sd, sigtimes, EEG, plot_pth, foc_nm)

    setsp = strsplit(EEG.setname,'_');
    subj = setsp{1};
    task = setsp{2};
    band = EEG.band;
    fs = EEG.srate;
    
    plt_max = max(dat+samp_sd);
    plt_min = min(dat-samp_sd);
    if plt_min > 0
        plt_min = -10;
    end

    warning('off')
    vis = 'off';
    figure('visible', vis,'color','white'); 
    hold on

    T = get_lock_times(EEG);
    
    % Plot data
    shade_plot(T.st:1000/fs:T.en, dat, samp_sd, rgb('steelblue'), 0.5, 1);
    
    % Plot vertical lines
    plot([0 0] ,[plt_min plt_max], 'k', 'LineWidth', 2);
    if T.scnd_mrk > T.en
        line([T.en T.en], [plt_min plt_max], 'LineStyle', '--', 'Color', 'y')
    elseif T.scnd_mrk < T.st
        line([T.st T.st], [plt_min plt_max], 'LineStyle', '--', 'Color', 'y')
    else
        plot([T.scnd_mrk T.scnd_mrk], [plt_min plt_max], '--', 'color', [.549, .549, .549])
    end

    % Plot horizontal lines
    plot([T.st     T.en], [0 0], 'k');
    plot([T.an_st  T.an_en], [0 0], 'k', 'LineWidth',2);
    plot([T.st     T.en], [10 10], '-k');
    
    sig_idc_adj = 1000*(sigtimes)/fs + T.an_st;
    for k = 1:size(sig_idc_adj,1)
        line([sig_idc_adj(k,1) sig_idc_adj(k,2)], [0 0], 'color', 'r', 'linewidth', 2)
%         line([sig_idc_adj(k,1) sig_idc_adj(k,1)], [0 dat(round((sig_idc_adj(k,1)-T.bl_st)*fs/1000))],'color','r')
%         line([sig_idc_adj(k,2) sig_idc_adj(k,2)], [0 dat(round((sig_idc_adj(k,2)-T.bl_st)*fs/1000))],'color','r')
    end

    % Edit plot
    set(gcf, 'Units','pixels','Position',[100 100 800 600])
    title(sprintf('Significant %s Activity %s - Channel %s - %s Task', band, subj, lab, task))
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    xlim(gca, [T.st T.en])
    ylim(gca, [plt_min plt_max])
    axis tight
    grid on

    % Save
    saveas(gca, sprintf('%s/%s_%s.png', plot_pth, foc_nm, lab))
    close

end