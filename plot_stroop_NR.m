function plot_stroop_NR(EEG, dat_files, study, cnum)
    
    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs';
    end
    
    sid = strsplit(EEG.setname, '_');
    subj = sid{1};  
    fs = EEG.srate;
    lock = EEG.lock{end};
    band = EEG.band{end};
    ref = EEG.ref;
    rtm = [EEG.event.resp]';
    
    ap_pth = sprintf('%s/plots/%s/%s', subjs_dir, study, lock);
    if cnum == 1
        my_mkdir(ap_pth, sprintf('%s_%s_*', subj, band))
    end
    
    switch lock
        case 'Response Locked'
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
            second_mrk = -mean(rtm);
        case 'Stimulus Locked'
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
            second_mrk = mean(rtm);
    end
    
    
    ch_lab = strsplit(dat_files{1}, '_');
    ch_lab = ch_lab{3};
        
    fcCc_beg = dat_files{cellfun(@(x) contains(x,'cCcBeg'), dat_files)};
    cCc_beg = load(fcCc_beg);
    
    fcCc_end = dat_files{cellfun(@(x) contains(x,'cCcEnd'), dat_files)};
    cCc_end = load(fcCc_end);
    
    fcIc_beg = dat_files{cellfun(@(x) contains(x,'cIcBeg'), dat_files)};
    cIc_beg = load(fcIc_beg);
    
    fcIc_end = dat_files{cellfun(@(x) contains(x,'cIcEnd'), dat_files)};
    cIc_end = load(fcIc_end);
    
    fcCs_beg = dat_files{cellfun(@(x) contains(x,'cCsBeg'), dat_files)};
    cCs_beg = load(fcCs_beg);
    
    fcCs_end = dat_files{cellfun(@(x) contains(x,'cCsEnd'), dat_files)};
    cCs_end = load(fcCs_end);
    
    fcIs_beg = dat_files{cellfun(@(x) contains(x,'cIsBeg'), dat_files)};
    cIs_beg = load(fcIs_beg);
    
    fcIs_end = dat_files{cellfun(@(x) contains(x,'cIsEnd'), dat_files)};
    cIs_end = load(fcIs_end);
    
    
    
    fsCc_beg = dat_files{cellfun(@(x) contains(x,'sCcBeg'), dat_files)};
    sCc_beg = load(fsCc_beg);
    
    fsCc_end = dat_files{cellfun(@(x) contains(x,'sCcEnd'), dat_files)};
    sCc_end = load(fsCc_end);
    
    fsIc_beg = dat_files{cellfun(@(x) contains(x,'sIcBeg'), dat_files)};
    sIc_beg = load(fsIc_beg);
    
    fsIc_end = dat_files{cellfun(@(x) contains(x,'sIcEnd'), dat_files)};
    sIc_end = load(fsIc_end);
    
    fsCs_beg = dat_files{cellfun(@(x) contains(x,'sCsBeg'), dat_files)};
    sCs_beg = load(fsCs_beg);
    
    fsCs_end = dat_files{cellfun(@(x) contains(x,'sCsEnd'), dat_files)};
    sCs_end = load(fsCs_end);
    
    fsIs_beg = dat_files{cellfun(@(x) contains(x,'sIsBeg'), dat_files)};
    sIs_beg = load(fsIs_beg);
    
    fsIs_end = dat_files{cellfun(@(x) contains(x,'sIsEnd'), dat_files)};
    sIs_end = load(fsIs_end);
    
    figure('visible', 'off')
    %figure
    set(gcf, 'Units','pixels','Position',[0 0 1920 1116])
    if second_mrk > en_tm
        second_mrk = en_tm;
    elseif second_mrk < st_tm
        second_mrk = st_tm;
    end
    
    c1 = [51 102 0]/255;
    c2 = [99 198 0]/255;
    c3 = [76 0 153]/255;
    c4 = [204 153 255]/255;
    delt = 10;
    
    if strcmp(band, 'HFB')
        fc = 16;
        [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
        cCcB_dat = filter(bb,aa,mean(cCc_beg.chnl_evnt,1));
        cIcB_dat = filter(bb,aa,mean(cIc_beg.chnl_evnt,1));
        cCsB_dat = filter(bb,aa,mean(cCs_beg.chnl_evnt,1));
        cIsB_dat = filter(bb,aa,mean(cIs_beg.chnl_evnt,1));


        cCcE_dat = filter(bb,aa,mean(cCc_end.chnl_evnt,1));
        cIcE_dat = filter(bb,aa,mean(cIc_end.chnl_evnt,1));
        cCsE_dat = filter(bb,aa,mean(cCs_end.chnl_evnt,1));
        cIsE_dat = filter(bb,aa,mean(cIs_end.chnl_evnt,1));


        sCcB_dat = filter(bb,aa,mean(sCc_beg.chnl_evnt,1));
        sIcB_dat = filter(bb,aa,mean(sIc_beg.chnl_evnt,1));
        sCsB_dat = filter(bb,aa,mean(sCs_beg.chnl_evnt,1));
        sIsB_dat = filter(bb,aa,mean(sIs_beg.chnl_evnt,1));


        sCcE_dat = filter(bb,aa,mean(sCc_end.chnl_evnt,1));
        sIcE_dat = filter(bb,aa,mean(sIc_end.chnl_evnt,1));
        sCsE_dat = filter(bb,aa,mean(sCs_end.chnl_evnt,1));
        sIsE_dat = filter(bb,aa,mean(sIs_end.chnl_evnt,1));
    else
        cCcB_dat = mean(cCc_beg.chnl_evnt,1);
        cIcB_dat = mean(cIc_beg.chnl_evnt,1);
        cCsB_dat = mean(cCs_beg.chnl_evnt,1);
        cIsB_dat = mean(cIs_beg.chnl_evnt,1);


        cCcE_dat = mean(cCc_end.chnl_evnt,1);
        cIcE_dat = mean(cIc_end.chnl_evnt,1);
        cCsE_dat = mean(cCs_end.chnl_evnt,1);
        cIsE_dat = mean(cIs_end.chnl_evnt,1);


        sCcB_dat = mean(sCc_beg.chnl_evnt,1);
        sIcB_dat = mean(sIc_beg.chnl_evnt,1);
        sCsB_dat = mean(sCs_beg.chnl_evnt,1);
        sIsB_dat = mean(sIs_beg.chnl_evnt,1);


        sCcE_dat = mean(sCc_end.chnl_evnt,1);
        sIcE_dat = mean(sIc_end.chnl_evnt,1);
        sCsE_dat = mean(sCs_end.chnl_evnt,1);
        sIsE_dat = mean(sIs_end.chnl_evnt,1);
    end
    
    
    max_cb = max(max([cCcB_dat,cIcB_dat,cCsB_dat,cIsB_dat]))+delt;
    min_cb = min(min([cCcB_dat,cIcB_dat,cCsB_dat,cIsB_dat]))-delt;
    max_ce = max(max([cCcE_dat,cIcE_dat,cCsE_dat,cIsE_dat]))+delt;
    min_ce = min(min([cCcE_dat,cIcE_dat,cCsE_dat,cIsE_dat]))-delt;
    max_sb = max(max([sCcB_dat,sIcB_dat,sCsB_dat,sIsB_dat]))+delt;
    min_sb = min(min([sCcB_dat,sIcB_dat,sCsB_dat,sIsB_dat]))-delt;
    max_se = max(max([sCcE_dat,sIcE_dat,sCsE_dat,sIsE_dat]))+delt;
    min_se = min(min([sCcE_dat,sIcE_dat,sCsE_dat,sIsE_dat]))-delt;
    
    glb_max = max([max_cb max_ce max_sb max_se]);
    glb_min = min([min_cb min_ce min_sb min_se]);
    
    tsamp = floor((st_tm-begin_tm)*fs/1000)+1:floor((en_tm-begin_tm)*fs/1000)+1;
    tmesh = st_tm:1000/fs:en_tm;
    
    subplot(2,2,1); hold on;
    X(:,1) = plot(tmesh, cCcB_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'cCc');
    X(:,2) = plot(tmesh, cIcB_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'cIc');
    X(:,3) = plot(tmesh, cCsB_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'cCs');
    X(:,4) = plot(tmesh, cIsB_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'cIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
%     h = fill([tms fliplr(tms)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_cb max_cb], 'k', 'LineWidth', 1)
%     plot([second_mrk second_mrk], [min_cb max_cb], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_cb max_cb])
    hold off;
    
    subplot(2,2,2); hold on;
    X(:,1) = plot(tmesh, cCcE_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'cCc');
    X(:,2) = plot(tmesh, cIcE_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'cIc');
    X(:,3) = plot(tmesh, cCsE_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'cCs');
    X(:,4) = plot(tmesh, cIsE_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'cIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
%     h = fill([tms fliplr(tms)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_ce max_ce], 'k', 'LineWidth', 1)
%     plot([second_mrk second_mrk], [min_ce max_ce], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (second 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_ce max_ce])
    hold off;
    
    subplot(2,2,3); hold on;
    X(:,1) = plot(tmesh, sCcB_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'sCc');
    X(:,2) = plot(tmesh, sIcB_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'sIc');
    X(:,3) = plot(tmesh, sCsB_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'sCs');
    X(:,4) = plot(tmesh, sIsB_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'sIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
%     h = fill([tms fliplr(tms)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_sb max_sb], 'k', 'LineWidth', 1)
%     plot([second_mrk second_mrk], [min_sb max_sb], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Spatial Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_sb max_sb])
    hold off;
    
    subplot(2,2,4); hold on;
    X(:,1) = plot(tmesh, sCcE_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'sCc');
    X(:,2) = plot(tmesh, sIcE_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'sIc');
    X(:,3) = plot(tmesh, sCsE_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'sCs');
    X(:,4) = plot(tmesh, sIsE_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'sIs');
    plot([st_tm en_tm], [0 0],'k','LineWidth',1);
%     h = fill([tms fliplr(tms)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([second_mrk second_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_se max_se], 'k', 'LineWidth', 1)
%     plot([second_mrk second_mrk], [min_se max_se], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Spatial Stroop (second 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_se max_se])
    hold off;
    
    
    ap_fname = sprintf('%s/%s_%s_%s_%s.png', ap_pth, subj, band, ch_lab, ref);
    saveas(gca, ap_fname)

    close


end