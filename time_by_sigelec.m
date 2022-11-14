
% Preparation for clustering

location = 'San_Diego';
subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs', location);
subjs = {'sd09','sd10','sd14','sd18','sd19','sd21'};
% subjs = {'pt6', 'pt9', 'pt20', 'pt29'};
study = 'Stroop_CIC-CM';
% study = 'DA_GEN';
ref = 'bipolar';
bands = {'LFP', 'HFB'};
locks = {'stim','resp'};


for b = 1:length(bands)
    band = bands{b};
for l = 1:length(locks)
    lock = locks{l};
for n = 1:length(subjs)
    subj = subjs{n};
    lock_pth = sprintf('%s/%s/analysis/%s/%s/%s', subjs_dir, subj, study, ref, lock);
    tvdf = sprintf('%s/ALL/TvD/%s/ALL_%s_TvD.mat', lock_pth, band, band);
    dat_pth = sprintf('%s/ALL/data/%s', lock_pth, band);
    load(tvdf)
    lab = TvD(:,2);
    elecs_dat = [];
    for m = 1:length(lab)
        elec = lab{m};
        elecf = sprintf('%s/ALL_%s_%s_%s.mat', dat_pth, subj, elec, ref);
        load(elecf, 'chnl_evnt')
        datm = mean(chnl_evnt,1);
        elecs_dat(:,m) = datm';
    end
    save(sprintf('%s/%s_mean_sig_data.mat', dat_pth, subj), 'elecs_dat', 'lab')
end
end
end
