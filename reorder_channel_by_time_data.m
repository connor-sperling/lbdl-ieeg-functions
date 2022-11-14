function reorder_channel_by_time_data(subjs_dir, study, ref, locks, bands)

xl_dir = sprintf('%s/Excel Files',subjs_dir);
subjs = dir(sprintf('%s/sd*', subjs_dir));
subjs = {subjs.name};
for p = 1:length(subjs) % loop thru patients
    subj = subjs{p};
    stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
    for lockc = locks % loop thru time locks
        lock = char(lockc);
        for bandc = bands % loop thru frequency bands
            band = char(bandc);

            dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
            cd(dat_dir)
            dfile = dir('*.mat');
            dfile = {dfile.name}; % all stimuls event files
            dfile(cellfun(@(x) strcmp(x(1), '.') | contains(x, 'GRAY'), dfile)) = [];
            file = dfile{1};
            
            load(file,'evn_seg','evn','sig_lab')

            xl_nm = sprintf('significant_%s_%s_%s_%s_Desikan_Killiany_localization',study,ref,lock,band);
            loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
            subj_loc = loc(cellfun(@(x) strcmp(x, subj), loc.subj), :);
            chan_ordered = subj_loc.channel_organized;
            disp([subj '  ' lock '  ' band])

            [~,order] = ismember(chan_ordered, sig_lab);
            evn_seg = evn_seg(order,:,:);
            sig_lab = sig_lab(order);
            file = erase(file, '_.mat'); % temp 12/12
            save(file,'evn_seg','evn','sig_lab')

        end
    end
end
end