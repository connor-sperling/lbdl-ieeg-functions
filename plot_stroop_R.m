function plot_stroop_R(EEG, dat_files, study, cnum)
    
    if ispc
        subjs_dir = 'L:/iEEG_San_Diego/Subjs';
    elseif isunix
        subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs';
    end

    sid = strsplit(EEG.setname, '_');
    subj = sid{1};  
    fs = EEG.srate;
    lock = EEG.lock;
    band = EEG.band;
    ref = EEG.ref;
    
    ap_pth = sprintf('%s/plots/%s/%s', subjs_dir, study, lock);
    if cnum == 1
        my_mkdir(ap_pth, sprintf('%s_%s_*', subj, band))
    end

  
    T = get_lock_times(EEG);
    
    ch_lab = strsplit(dat_files{1}, '_');
    ch_lab = ch_lab{3};
        
    fCCcBeg = dat_files{cellfun(@(x) contains(x,'CCcBeg'), dat_files)};
    CCcBeg = load(fCCcBeg);
    
    fCCcEnd = dat_files{cellfun(@(x) contains(x,'CCcEnd'), dat_files)};
    CCcEnd = load(fCCcEnd);
    
    fCIcBeg = dat_files{cellfun(@(x) contains(x,'CIcBeg'), dat_files)};
    CIcBeg = load(fCIcBeg);
    
    fCIcEnd = dat_files{cellfun(@(x) contains(x,'CIcEnd'), dat_files)};
    CIcEnd = load(fCIcEnd);
    
    fICcBeg = dat_files{cellfun(@(x) contains(x,'ICcBeg'), dat_files)};
    ICcBeg = load(fICcBeg);
    
    fICcEnd = dat_files{cellfun(@(x) contains(x,'ICcEnd'), dat_files)};
    ICcEnd = load(fICcEnd);
    
    fIIcBeg = dat_files{cellfun(@(x) contains(x,'IIcBeg'), dat_files)};
    IIcBeg = load(fIIcBeg);
    
    fIIcEnd = dat_files{cellfun(@(x) contains(x,'IIcEnd'), dat_files)};
    IIcEnd = load(fIIcEnd);
    
    
    
    fCCsBeg = dat_files{cellfun(@(x) contains(x,'CCsBeg'), dat_files)};
    CCsBeg = load(fCCsBeg);
    
    fCCsEnd = dat_files{cellfun(@(x) contains(x,'CCsEnd'), dat_files)};
    CCsEnd = load(fCCsEnd);
    
    fCIsBeg = dat_files{cellfun(@(x) contains(x,'CIsBeg'), dat_files)};
    CIsBeg = load(fCIsBeg);
    
    fCIsEnd = dat_files{cellfun(@(x) contains(x,'CIsEnd'), dat_files)};
    CIsEnd = load(fCIsEnd);
    
    fICsBeg = dat_files{cellfun(@(x) contains(x,'ICsBeg'), dat_files)};
    ICsBeg = load(fICsBeg);
    
    fICsEnd = dat_files{cellfun(@(x) contains(x,'ICsEnd'), dat_files)};
    ICsEnd = load(fICsEnd);
    
    fIIsBeg = dat_files{cellfun(@(x) contains(x,'IIsBeg'), dat_files)};
    IIsBeg = load(fIIsBeg);
    
    fIIsEnd = dat_files{cellfun(@(x) contains(x,'IIsEnd'), dat_files)};
    IIsEnd = load(fIIsEnd);
    
    figure('visible', 'off')
    %figure
    set(gcf, 'Units','pixels','Position',[0 0 1920 1116])
    if T.scnd_mrk > T.en
        T.scnd_mrk = T.en;
    elseif T.scnd_mrk < T.st
        T.scnd_mrk = T.st;
    end
    
    c1 = [51 102 0]/255;
    c2 = [99 198 0]/255;
    c3 = [76 0 153]/255;
    c4 = [204 153 255]/255;
    delt = 10;
    
    if strcmp(band, 'HFB')
        fc = 16;
        [bb,aa] = butter(6,fc/(fs/2)); % Butterworth filter of order 6
        CCcB_dat = filter(bb,aa,mean(CCcBeg.chnl_evnt,1));
        CIcB_dat = filter(bb,aa,mean(CIcBeg.chnl_evnt,1));
        ICcB_dat = filter(bb,aa,mean(ICcBeg.chnl_evnt,1));
        IIcB_dat = filter(bb,aa,mean(IIcBeg.chnl_evnt,1));

        CCcE_dat = filter(bb,aa,mean(CCcEnd.chnl_evnt,1));
        CIcE_dat = filter(bb,aa,mean(CIcEnd.chnl_evnt,1));
        ICcE_dat = filter(bb,aa,mean(ICcEnd.chnl_evnt,1));
        IIcE_dat = filter(bb,aa,mean(IIcEnd.chnl_evnt,1));

        CCsB_dat = filter(bb,aa,mean(CCsBeg.chnl_evnt,1));
        CIsB_dat = filter(bb,aa,mean(CIsBeg.chnl_evnt,1));
        ICsB_dat = filter(bb,aa,mean(ICsBeg.chnl_evnt,1));
        IIsB_dat = filter(bb,aa,mean(IIsBeg.chnl_evnt,1));

        CCsE_dat = filter(bb,aa,mean(CCsEnd.chnl_evnt,1));
        CIsE_dat = filter(bb,aa,mean(CIsEnd.chnl_evnt,1));
        ICsE_dat = filter(bb,aa,mean(ICsEnd.chnl_evnt,1));
        IIsE_dat = filter(bb,aa,mean(IIsEnd.chnl_evnt,1));
    else
        CCcB_dat = mean(CCcBeg.chnl_evnt,1);
        CIcB_dat = mean(CIcBeg.chnl_evnt,1);
        ICcB_dat = mean(ICcBeg.chnl_evnt,1);
        IIcB_dat = mean(IIcBeg.chnl_evnt,1);

        CCcE_dat = mean(CCcEnd.chnl_evnt,1);
        CIcE_dat = mean(CIcEnd.chnl_evnt,1);
        ICcE_dat = mean(ICcEnd.chnl_evnt,1);
        IIcE_dat = mean(IIcEnd.chnl_evnt,1);
        
        CCsB_dat = mean(CCsBeg.chnl_evnt,1);
        CIsB_dat = mean(CIsBeg.chnl_evnt,1);
        ICsB_dat = mean(ICsBeg.chnl_evnt,1);
        IIsB_dat = mean(IIsBeg.chnl_evnt,1);

        CCsE_dat = mean(CCsEnd.chnl_evnt,1);
        CIsE_dat = mean(CIsEnd.chnl_evnt,1);
        ICsE_dat = mean(ICsEnd.chnl_evnt,1);
        IIsE_dat = mean(IIsEnd.chnl_evnt,1);

    end
    
    
    max_cb = max(max([CCcB_dat,CIcB_dat,ICcB_dat,IIcB_dat]))+delt;
    min_cb = min(min([CCcB_dat,CIcB_dat,ICcB_dat,IIcB_dat]))-delt;
    max_ce = max(max([CCcE_dat,CIcE_dat,ICcE_dat,IIcE_dat]))+delt;
    min_ce = min(min([CCcE_dat,CIcE_dat,ICcE_dat,IIcE_dat]))-delt;
    max_sb = max(max([CCsB_dat,CIsB_dat,ICsB_dat,IIsB_dat]))+delt;
    min_sb = min(min([CCsB_dat,CIsB_dat,ICsB_dat,IIsB_dat]))-delt;
    max_se = max(max([CCsE_dat,CIsE_dat,ICsE_dat,IIsE_dat]))+delt;
    min_se = min(min([CCsE_dat,CIsE_dat,ICsE_dat,IIsE_dat]))-delt;
    
    glb_max = max([max_cb max_ce max_sb max_se]);
    glb_min = min([min_cb min_ce min_sb min_se]);
    
    
    tsamp = floor((T.st-T.st)*fs/1000)+1:floor((T.en-T.st)*fs/1000)+1;
    tmesh = T.st:1000/fs:T.en;
    
    subplot(2,2,1); hold on;
    X(:,1) = plot(tmesh, CCcB_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'CC');
    X(:,2) = plot(tmesh, CIcB_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'CI');
    X(:,3) = plot(tmesh, ICcB_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'IC');
    X(:,4) = plot(tmesh, IIcB_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'II');
    plot([T.st T.en], [0 0],'k','LineWidth',1);
%     h = fill([tmesh fliplr(tms)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([T.scnd_mrk T.scnd_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_cb max_cb], 'k', 'LineWidth', 1)
%     plot([T.scnd_mrk T.scnd_mrk], [min_cb max_cb], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_cb max_cb])
    hold off;
    
    subplot(2,2,2); hold on;
    X(:,1) = plot(tmesh, CCcE_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'CC');
    X(:,2) = plot(tmesh, CIcE_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'CI');
    X(:,3) = plot(tmesh, ICcE_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'IC');
    X(:,4) = plot(tmesh, IIcE_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'II');
    plot([T.st T.en], [0 0],'k','LineWidth',1);
%     h = fill([tmesh fliplr(tmesh)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([T.scnd_mrk T.scnd_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_ce max_ce], 'k', 'LineWidth', 1)
%     plot([T.scnd_mrk T.scnd_mrk], [min_ce max_ce], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Color Stroop (second 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_ce max_ce])
    hold off;
    
    subplot(2,2,3); hold on;
    X(:,1) = plot(tmesh, CCsB_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'CC');
    X(:,2) = plot(tmesh, CIsB_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'CI');
    X(:,3) = plot(tmesh, ICsB_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'IC');
    X(:,4) = plot(tmesh, IIsB_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'II');
    plot([T.st T.en], [0 0],'k','LineWidth',1);
%     h = fill([tmesh fliplr(tmesh)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([T.scnd_mrk T.scnd_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_sb max_sb], 'k', 'LineWidth', 1)
%     plot([T.scnd_mrk T.scnd_mrk], [min_sb max_sb], '--', 'color', [.549, .549, .549])
    title([subj ' ' ch_lab ' - ' lock ' - Spatial Stroop (first 20 stimuli)'])
    legend(X, 'Location', 'northwest')
    xlabel('Time (ms)')
    ylabel('Change from Baseline (%)')
    ylim([glb_min glb_max])
%     ylim([min_sb max_sb])
    hold off;
    
    subplot(2,2,4); hold on;
    X(:,1) = plot(tmesh, CCsE_dat(tsamp), 'color', c1, 'Linewidth', 2, 'DisplayName', 'CC');
    X(:,2) = plot(tmesh, CIsE_dat(tsamp), 'color', c2, 'Linewidth', 2, 'DisplayName', 'CI');
    X(:,3) = plot(tmesh, ICsE_dat(tsamp), 'color', c3, 'Linewidth', 2, 'DisplayName', 'IC');
    X(:,4) = plot(tmesh, IIsE_dat(tsamp), 'color', c4, 'Linewidth', 2, 'DisplayName', 'II');
    plot([T.st T.en], [0 0],'k','LineWidth',1);
%     h = fill([tmesh fliplr(tmesh)],shadow,[200/255, 200/255, 200/255]);
%     set(h,'EdgeColor',[200/255, 200/255, 200/255],'FaceAlpha',.7,'EdgeAlpha',.7);%set edge color
    plot([0 0], [glb_min glb_max], 'k', 'LineWidth', 1)
    plot([T.scnd_mrk T.scnd_mrk], [glb_min glb_max], '--', 'color', [.549, .549, .549])
%   Relative scaling (be sure to change ylim if you use this)
%     plot([0 0], [min_se max_se], 'k', 'LineWidth', 1)
%     plot([T.scnd_mrk T.scnd_mrk], [min_se max_se], '--', 'color', [.549, .549, .549])
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