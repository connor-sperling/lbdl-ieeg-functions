function ax = plot_by_focus(cpth, sdarea, resp, task, lock_typ, gsize, fs, ALL_shadow)

    cd(cpth)
    d = dir;
    files = {d.name};
    files = files(cellfun(@(x) contains(x,'.mat'), files));

    
    switch lock_typ
        case 'r' 
            st_tm = -1250;
            en_tm = 250;
            second_mrk = -mean(resp(resp > 0));
        case 's'
            st_tm = -500;
            en_tm = 1000;
            second_mrk = mean(resp(resp > 0));
    end
    
    figure('visible', 'off')
    %figure
    hold on
    sd_shade = [176 176 176]./255;
    rst = 40; gst = 30; bst = 0;
    r = rst/255; g = gst/255; b = bst/255;
    cats = [];
    sdp_max = 0;
    sdm_min = 0;
    minplot = 0;
    maxplot = 0;

    for ii = 1:length(files)

        [r, g, b] = rgb_grad(r, g, b, rst, gst, bst, length(files));
        c = [r, g, b];
    
        C = load(files{ii}, 'chnl_evnt');
        chnl_evnt = C.chnl_evnt;

        file_id = strsplit(files{ii}, '_');
        
        % THIS MAY ONLY BE UNIQUE TO NAMING TASK
        cat_typ = file_id{1};
        cat_nm = cat_typ(isletter(cat_typ));
        cat_no_s = cat_typ(~isletter(cat_typ));
        if isnan(str2double(cat_typ(~isletter(cat_typ))))
            grp_stsp = cellfun(@str2double, strsplit(cat_no_s, '-'));
            cats = [cats grp_stsp(1):grp_stsp(2)];
        else
            cats = [cats str2double(cat_no_s)];
        end
        pt_nm = file_id{2};
        chan = file_id{3};
        ref = erase(file_id{4}, ".mat");

        %dat = smoothdata(mean(chnl_evnt,1), 'gaussian', round(50/1000*fs));
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
        
        X(:,ii) = plot(st_tm:1000/fs:en_tm, dat, 'color', c, 'Linewidth', 2, 'DisplayName', ['Pos. in Cat.: ' cat_no_s]);

    end
    
    plot([0 0] ,[minplot-20 maxplot+20], 'LineWidth', 2, 'Color', 'k');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    if ALL_shadow
        h = fill([st_tm:1000/fs:en_tm fliplr(st_tm:1000/fs:en_tm)], sdarea, sd_shade);
        set(h, 'EdgeColor', sd_shade,'FaceAlpha', 0.5,'EdgeAlpha', 0.1);
    end
    if second_mrk > en_tm
        line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    elseif second_mrk < st_tm
        line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    else
        plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    end
    
    % THIS MAY ONLY BE UNIQUE TO NAMING TASK
    dcat = [false diff(cats) == 1];
    disp_cat = '';
    for ii = 1:length(dcat)
        if ii == length(dcat)
            disp_cat = [disp_cat num2str(cats(ii))];
        elseif dcat(ii) == 0 && dcat(ii+1) == 0
            disp_cat = [disp_cat num2str(cats(ii)) ' '];
        elseif dcat(ii) == 0 && dcat(ii+1) == 1 
            disp_cat = [disp_cat num2str(cats(ii)) '-'];
        elseif dcat(ii) == 1 && dcat(ii+1) == 0
            disp_cat = [disp_cat num2str(cats(ii)) ' '];
        end
    end
    
    if strcmpi(lock_typ, 's')
        lock = 'Stim';
    elseif strcmpi(lock_typ, 'r')
        lock = 'Resp';
    end
    
    
    grid on
    title(sprintf('%s %s task, Channel %s - %s ref. - %s Locked', pt_nm, task, chan, ref, lock))
    xlim([st_tm en_tm])
    ylim([minplot-10 maxplot+10])
    legend(X)
    if gsize > 1
        plt_fname = [pt_nm '_' chan '_' ref '_' cat_nm '_' disp_cat '_group' num2str(gsize) '.jpeg'];
        fig_fname = [pt_nm '_' chan '_' ref '_' cat_nm '_' disp_cat '_group' num2str(gsize) '.fig'];
    else
        plt_fname = [pt_nm '_' chan '_' ref '_' cat_nm '_' disp_cat '.jpeg'];
        fig_fname = [pt_nm '_' chan '_' ref '_' cat_nm '_' disp_cat '.fig'];
    end
    
    ax = gca;
    saveas(gca, plt_fname)
    saveas(gcf, fig_fname)

    ax.Title.String = chan;
end