function plot_DA_DV(EEG, study1)

    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_Marseille/Subjs';
    end
    
    study_splt = strsplit(study1, '_');
    task1 = study_splt{1};
    if strcmp(task1, 'DA')
        task2 = 'DV';
    else
        task2 = 'DA'; 
    end
    study2 = sprintf('%s_%s',task2,study_splt{2});
    
    sid = strsplit(EEG.setname, '_');
    subj = sid{1};      
    fs = EEG.srate;
%     rtm = [EEG.event.resp]';
    band = EEG.band;
    ref = EEG.ref;
    lock = EEG.lock;   
    
    prim_an_dir = sprintf('%s/%s/analysis/%s/%s/%s/ALL',subjs_dir,subj,study1,ref,lock);
    secn_an_dir = sprintf('%s/%s/analysis/%s/%s/%s/ALL',subjs_dir,subj,study2,ref,lock);
    if ~exist(secn_an_dir, 'dir')
        return
    end
    ap_pth = sprintf('%s/plots/%s/%s', subjs_dir, study1, lock);

    switch lock
        case 'resp'
            lnm = 'RL';
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
%             second_mrk = -mean(rtm);
        case 'stim'
            lnm = 'SL';
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
%             second_mrk = mean(rtm);
    end
    
    % Load TvD from primary
    load(sprintf('%s/TvD/%s/ALL_%s_TvD.mat',prim_an_dir,band,band),'TvD');
    sig_chans_prim = TvD(:,2);
    
    load(sprintf('%s/TvD/%s/ALL_%s_TvD.mat',secn_an_dir,band,band),'TvD');
    sig_chans_secn = TvD(:,2);
    
    for k = 1:length(sig_chans_prim)
        
        load(sprintf('%s/data/%s/ALL_%s_%s_%s.mat',prim_an_dir,band,subj,sig_chans_prim{k},ref), 'chnl_evnt')
        chnl_evnt_prim = chnl_evnt;
        
        if exist(sprintf('%s/data/%s/ALL_%s_%s_%s.mat',secn_an_dir,band,subj,sig_chans_prim{k},ref), 'file')
            load(sprintf('%s/data/%s/ALL_%s_%s_%s.mat',secn_an_dir,band,subj,sig_chans_prim{k},ref), 'chnl_evnt')
            chnl_evnt_secn = chnl_evnt;
        else
            figure('visible', 'off')
    %         figure
            set(gcf, 'Units','pixels','Position',[100 100 800 600])
            hold on

            pclr = [0,   85,  196]./255;
            if strcmp(band, 'HFB')
                fc = 14;
                [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
                dat_p = filter(bb,aa,mean(chnl_evnt_prim,1));
            else
                dat_p = mean(chnl_evnt_prim,1);
            end

            mindat = min(dat_p);
            maxdat = max(dat_p);

            tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
            tmesh = st_tm:1000/fs:en_tm;
            dat_p = dat_p(tsamp);

            X(:,1) = plot(tmesh, dat_p, 'color', pclr, 'Linewidth', 2, 'DisplayName', task1);

            plot([0 0] ,[mindat-20 maxdat+20], 'LineWidth', 1, 'Color', 'k');
            plot([st_tm en_tm], [0 0],'k','LineWidth',1);
    %         if second_mrk > en_tm
    %             line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    %         elseif second_mrk < st_tm
    %             line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
    %         else
    %             plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
    %         end

            title(sprintf('Avg. %s Activity - %s - %s - %s - %s', band, subj, sig_chans_prim{k}, ref, lnm))
            xlim([st_tm en_tm])
            ylim([mindat-10 maxdat+10])
            xlabel('Time (ms)');
            ylabel('Change from Baseline (%)');
            legend(task1)
            grid on

            ap_fname = sprintf('%s/%s_%s_%s_%s.png', ap_pth, subj, band, sig_chans_prim{k}, ref);
            saveas(gca, ap_fname)

            close
            continue
        end

        figure('visible', 'off')
%         figure
        set(gcf, 'Units','pixels','Position',[100 100 800 600])
        hold on
        
        if strcmp(task1,'DA')
            pclr = [0,    85,  196]./255;
        else
            pclr = [0,   200,  255]./255;
        end
        
        if ismember(sig_chans_prim{k}, sig_chans_secn)
            if strcmp(task1,'DA')
                sclr = [0,    85,  196]./255;
            else
                sclr = [0,   200,  255]./255;
            end
        else
            sclr = [210, 180, 126]./255;
        end
            
        if strcmp(band, 'HFB')
            fc = 14;
            [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
            dat_p = filter(bb,aa,mean(chnl_evnt_prim,1));
            dat_s = filter(bb,aa,mean(chnl_evnt_secn,1));
        else
            dat_p = mean(chnl_evnt_prim,1);
            dat_s = mean(chnl_evnt_secn,1);
        end
        
        mindat = min([dat_p dat_s]);
        maxdat = max([dat_p dat_s]);

        tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
        tmesh = st_tm:1000/fs:en_tm;
        dat_p = dat_p(tsamp);
        dat_s = dat_s(tsamp);
        
        X(:,1) = plot(tmesh, dat_p, 'color', pclr, 'Linewidth', 2, 'DisplayName', task1);
        X(:,2) = plot(tmesh, dat_s, 'color', sclr, 'Linewidth', 2, 'DisplayName', task2);

        plot([0 0] ,[mindat-20 maxdat+20], 'LineWidth', 1, 'Color', 'k');
        plot([st_tm en_tm], [0 0],'k','LineWidth',1);
%         if second_mrk > en_tm
%             line([en_tm en_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
%         elseif second_mrk < st_tm
%             line([st_tm st_tm], [minplot-10 maxplot+10], 'LineStyle', '--', 'Color', 'y')
%         else
%             plot([second_mrk second_mrk], [minplot-10 maxplot+10], '--', 'color', [.549, .549, .549])
%         end


        title(sprintf('Avg. %s Activity - %s - %s - %s - %s', band, subj, sig_chans_prim{k}, ref, lnm))
        xlim([st_tm en_tm])
        ylim([mindat-10 maxdat+10])
        xlabel('Time (ms)');
        ylabel('Change from Baseline (%)');
        legend(X, 'Location', 'northwest')
        grid on

        ap_fname = sprintf('%s/%s_%s_%s_%s.png', ap_pth, subj, band, sig_chans_prim{k}, ref);
        saveas(gca, ap_fname)

        close
    end
end