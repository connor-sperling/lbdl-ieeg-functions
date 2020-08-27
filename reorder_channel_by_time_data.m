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
        dfiles = dir('*.mat');
        dfiles = {dfiles.name}; % all stimuls event files
        
        xl_nm = sprintf('significant_%s_%s_%s_%s_Desikan_Killiany_localization',study,ref,lock,band);
        loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
        subj_loc = loc(cellfun(@(x) strcmp(x, subj), loc.subj), :);
        chan_ordered = subj_loc.channel_organized;
        disp([subj '  ' lock '  ' band])
        
        for ii = 1:length(dfiles)
            fname = dfiles{ii};
            load(fname, 'evn_seg', 'sig_lab')
            [~,order] = ismember(chan_ordered, sig_lab);
            evn_seg = evn_seg(order,:);
            sig_lab = sig_lab(order);
            save(fname, 'evn_seg', 'sig_lab')
        end
    end
    end
    

end
end