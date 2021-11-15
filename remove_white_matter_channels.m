function remove_white_matter_channels(subjs_dir, atlas, study, ref, locks, bands)
    
    xl_dir = sprintf('%s/Excel Files',subjs_dir);
    for l = 1:length(locks)
        lock = locks{l};
        for b = 1:length(bands)
            band = bands{b};  
            loc = readtable(sprintf('%s/significant_%s_%s_%s_%s_%s_localization.xlsx',xl_dir,study,ref,lock,band,atlas));
            [subjs, ~, subj_num] = unique(loc.subj);
            loc_gray = cell2table(cell(0,8), 'variableNames', loc.Properties.VariableNames);
            for p = 1:length(subjs)
                subj = subjs{p};
                fprintf('%s %s %s\n', subj, lock, band)
                subj_msk = subj_num == p;
                loc_subj = loc(subj_msk,:);
                regions = loc_subj.region;
                rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
                region_only = cellfun(@(x) x{2}, rsplt, 'uni', 0);
                wm_msk = cellfun(@(x) strcmp(x, 'WM') | strcmp(x, 'U') | strcmp(x, 'blanc') | strcmp(x, 'out'), region_only);
                loc_subj(wm_msk,:) = [];
                loc_gray = [loc_gray; loc_subj];
                
                dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
                my_mkdir(dat_dir, '*_GRAY.mat')
                cd(dat_dir)
                dfile = dir('*.mat');
                dfile = {dfile.name}; % all stimuls event files
                dfile(cellfun(@(x) strcmp(x(1), '.'), dfile)) = [];
                file = dfile{1};
                load(file, 'evn_seg', 'evn', 'sig_lab')

                evn_seg(wm_msk,:,:) = [];
                sig_lab(wm_msk) = [];
                
                file = erase(file, '.mat');
                save(sprintf('%s_GRAY.mat', file), 'evn_seg', 'evn', 'sig_lab')
            end
            writetable(loc_gray, sprintf('%s/significant_GRAY_%s_%s_%s_%s_%s_localization.xlsx',xl_dir,study,ref,lock,band,atlas))
        end
    end
end