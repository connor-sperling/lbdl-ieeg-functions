function make_hfb_plots (hga_pth, chnl_dirs, srate, lock_typ, task)

    stim = 0/1000*srate;
    ticks_tp = round(250./1000*srate); %plotting
    chunksize = 100/1000*srate;
    q = 0.05;
    if ~iscell(chnl_dirs)
        chnl_dirs = cellstr(chnl_dirs);
    end
    
    for ii = 1:length(chnl_dirs)
        
        
        cd(chnl_dirs{ii})
        d = dir;
        hfb_mats = {d.name};
        hfb_mats = hfb_mats(cellfun(@(x) contains(x, '.mat'), hfb_mats));
        
        k = 0;
        X = [];
        
        if ~contains(chnl_dirs{1}, 'ALL')
            hold on
            figure(1)
        end
        rst = 40; gst = 30; bst = 0;
        r = rst/255; g = gst/255; b = bst/255;
        foc_typs = {};
        for h = 1:length(hfb_mats)
            if ~contains(chnl_dirs{1}, 'ALL')
                [r, g, b] = rgb_move(r, g, b, rst, gst, bst, length(hfb_mats));
                c = [r, g, b];
                %lc = c;
                %colorset = colorset(~cellfun(@(x) sum(x) == sum(c), colorset));
                %c = hex2rgb(c);
            else
                c = 'b';
            end
            k = k + 1;
            mat_nm = strsplit(hfb_mats{h}, '_');
            foc_typ = mat_nm{1};
            pt_nm = mat_nm{2};
            foc_typs = [foc_typs mat_nm(1)];
            chan_nm = mat_nm{3};
            if ~contains(chnl_dirs{1}, 'ALL')
                folder_nm = ['channel_' chan_nm];
            else
                folder_nm = 'All';
            end
            
            switch lock_typ
            case 'r'
                lock_nm = 'Resp. Locked';
                start_time_window = -1500;
                tm_st  = round( start_time_window ./1000*srate);
                tm_en  = round( 500 ./1000*srate);
                st_new = -750;
                en_new = round( 250 ./1000*srate);
                fig_pth = [hga_pth folder_nm '/Response Locked/'];
                plt_pth = [fig_pth 'plots/'];
                tvd_pth = [hga_pth foc_typ '/Response Locked/TvD/'];
            case 's'
                lock_nm = 'Stim. Locked';
                start_time_window = -1000;
                tm_st  = round( start_time_window ./1000*srate);
                tm_en  = round( 2000 ./1000*srate);
                st_new = 0;
                en_new = round( 1000 ./1000*srate);
                fig_pth = [hga_pth folder_nm '/Stimulus Locked/'];
                plt_pth = [fig_pth 'plots/'];
                tvd_pth = [hga_pth foc_typ '/Stimulus Locked/TvD/'];
            end
            
            plot_jump = 500;
            jm = round(plot_jump./1000*srate);
        
            load([tvd_pth 'TvD.mat'])

            load(char(hfb_mats{h}));
            warning('off')

            
            semT = squeeze(std(chnl_evnt(:,:))/sqrt(size(chnl_evnt,1)))';
            scalemax = max(max(squeeze(mean(chnl_evnt(:,:)))+semT'));
            scalemin = min(min(squeeze(mean(chnl_evnt(:,:)))-semT'));
            if scalemin > 0
                scalemin = -10;
            end
            
            
            if ~contains(chnl_dirs{1}, 'ALL')
                if k == 1
                    %figure('color','white');
                    set(gcf,'Units','pixels','Position',[100 100 800 600])
                    for z = 1:length((tm_st:jm:tm_en))
                        plot_str{z} = start_time_window + (z-1)*plot_jump;
                    end
                    set(gca,'XTick',(tm_st:jm:tm_en),'XTickLabel',plot_str,'XTickMode',...
                    'manual','Layer','top');
                    
                    axis tight
                    grid on
                    xlim([tm_st tm_en])
                    xlabel('ms'); ylabel('% change from baseline');
                end
            else
                figure( 'visible', 'off', 'color','white');
                set(gcf,'Units','pixels','Position',[100 100 800 600])
                for z = 1:length((tm_st:jm:tm_en))
                    plot_str{z} = start_time_window + (z-1)*plot_jump;
                end
                set(gca,'XTick',(tm_st:jm:tm_en),'XTickLabel',plot_str,'XTickMode',...
                'manual','Layer','top');
                
                xlim([tm_st tm_en])
                xlabel('ms'); ylabel('% change from baseline');
            end
            
            if contains(chnl_dirs{1}, 'ALL')
                shade_plot(tm_st:tm_en, squeeze(mean(chnl_evnt(:,:))), semT', rgb('steelblue'),0.5,1);
            else
                X(:,k) = plot(tm_st:tm_en, squeeze(mean(chnl_evnt(:,:))), 'color', c, 'linewidth', 2, 'DisplayName', foc_typ); hold on
            
            end
            plot([stim stim] ,[scalemin scalemax], '--','LineWidth',2, 'Color',rgb('SlateGray')); hold on
           
            plot([tm_st tm_en], [0 0],'k','LineWidth',1); hold on
            plot([st_new tm_en], [0 0],'k','LineWidth',3); hold on
            start_idx = TvD{k,5}(:,1)+tm_st;
            end_idx = TvD{k,5}(:,2)+tm_st;

            for i = 1:length(start_idx)
                plot((start_idx(i):end_idx(i)), zeros(1,length(start_idx(i):end_idx(i))),'color', 'r', 'LineWidth',3); hold on

            end

            
            if contains(chnl_dirs{1}, 'ALL')
                title(sprintf('%s Channel %s - %s - %s', pt_nm, chan_nm, lock_nm, task))
                axis tight
                grid on
                print('-dpng',sprintf('%se_%s_%2.2f_%ims.png',plt_pth, chan_nm, q, chunksize))
                saveas(gcf, sprintf('%se_%s_%2.2f_%ims.fig', fig_pth, chan_nm, q, chunksize))
                close
            end

        end
        
        if ~contains(chnl_dirs{1}, 'ALL')
            t = sprintf('%s Channel %s - %s - %s', pt_nm, chan_nm, lock_nm, task);
            png_nm = [plt_pth 'e_' chan_nm];
            fig_nm = [fig_pth 'e_' chan_nm];
            for f = 1:length(foc_typs)
                %t = sprintf('%s %s, ', t, foc_typs{f});
                png_nm = sprintf('%s_%s', png_nm, foc_typs{f});
                fig_nm = sprintf('%s_%s', fig_nm, foc_typs{f});
            end
            %t = sprintf('%s - one-sided -  > zero for >%ims', t, chunksize/srate*1000);
            png_nm = sprintf('%s%2.2f_%ims.png',png_nm, q, chunksize);
            fig_nm = sprintf('%s%2.2f_%ims.fig',fig_nm, q, chunksize);
            title(t)
            if length(X) < 10
                legend(X)
            end
            
            axis tight
            grid on
            
            print('-dpng',[png_nm '.png'])
            saveas(gcf, [fig_nm '.fig'])
            close
        end
    end
end