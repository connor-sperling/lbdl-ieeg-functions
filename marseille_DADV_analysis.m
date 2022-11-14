subj = 'pt29';
task = {'DA'};
subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_Marseille/Subjs';

bands = {'HFB', 'LFP'};
locks = {'stim', 'resp'};

cmat = [0,   85,  196;...
        210, 180, 126]./255;
        
for k = 1:length(bands)
    band = bands{k};
    disp(band)
    for j = 1:length(locks)
        lock = locks{j};
        disp(lock)
        my_mkdir(sprintf('%s/%s/analysis/GEN/bipolar/%s/data/%s', subjs_dir, subj, lock, band), '*.mat');
        my_mkdir(sprintf('%s/%s/analysis/GEN/bipolar/%s/plots/%s', subjs_dir, subj, lock, band), '*.png');
        my_mkdir(sprintf('%s/%s/analysis/GEN/bipolar/%s/TvD', subjs_dir, subj, lock), '*.mat');
        fdat_pth = sprintf('%s/%s/analysis/GEN/bipolar/%s/data/%s', subjs_dir, subj, lock, band);
        lock_pth = sprintf('%s/%s/analysis/GEN/bipolar/%s', subjs_dir, subj, lock);
        sig_all = {};
        for i = 1:length(task)
            foc_nm = task{i};
            disp(foc_nm)
            load(sprintf('%s/%s/Data Files/%s_%s_GEN_bipolarNEW_dat.mat', subjs_dir, subj, subj, foc_nm));
        
            EEG.band = {band};
            EEG.lock = {lock};
                
            evn = {EEG.analysis.type}';
            evn_idc = [EEG.analysis.latency]';
            rtm = [EEG.analysis.resp]';

            event_prep(EEG, evn, evn_idc, rtm, fdat_pth, foc_nm);
            TvD = sig_freq_band(EEG, rtm, lock_pth, foc_nm);
            sig_all = [sig_all; TvD(:,2)];
        end

        cd(fdat_pth)
        for ii = 1:length(sig_all)
            chan_mats_struc = dir(sprintf('*%s_%s_bipolar*', subj, sig_all{ii}));
            channel_mats = {chan_mats_struc.name};
            plot_conditions_marseille(channel_mats, sig_all{ii}, subj, lock, band, cmat);
        end
    end
end



