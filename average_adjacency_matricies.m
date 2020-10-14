function average_adjacency_matricies(subjs_dir, study, ref, atlas, abr, separation, conditions)

dpth = sprintf('%s/thesis/data/%s/adjacency_matricies', subjs_dir, study);
cmpth = sprintf('%s/thesis/plots/%s/average_%s', subjs_dir, study, separation);
spth = sprintf('%s/thesis/data/%s/average_%s', subjs_dir, study, separation);

xl_dir = sprintf('%s/Excel Files',subjs_dir);
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end

files_sd = dir(sprintf('%s/sd*', dpth));
files_m = dir(sprintf('%s/m*', dpth));
files_sd = {files_sd.name};
files_m = {files_m.name};

if ~isempty(files_sd)
    files = files_sd;
else
    files = files_m;
end

files_splt = cellfun(@(x) strsplit(x, '_'), files, 'uni', 0);
[subjs, ~, subjs_num] = unique(cellfun(@(x) x{1}, files_splt, 'uni', 0));

for p = 1:length(subjs) % loop thru patients
    subj = subjs{p};
    f_subj = files(p == subjs_num);
    f_subj_splt = cellfun(@(x) strsplit(x, '_'), f_subj, 'uni', 0);
    [locks, ~, locks_num] = unique(cellfun(@(x) x{3}, f_subj_splt, 'uni', 0));
    for l = 1:length(locks) % loop thru time locks
        lock = locks{l};
        f_subj_lock = f_subj(l == locks_num);
        f_subj_lock_splt = cellfun(@(x) strsplit(x, '_'), f_subj_lock, 'uni', 0);
        [bands, ~, bands_num] = unique(cellfun(@(x) x{4}, f_subj_lock_splt, 'uni', 0));
        for b = 1:length(bands) % loop thru frequency bands
            band = bands{b};
            fprintf('\n%s %s %s\n', subj, lock, band)
            my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
            my_mkdir(spth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        
            if abr % For connectivity maps
                xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
                loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
            else
                loc = [];
            end

            f_subj_lock_band = f_subj_lock(b == bands_num);
            
            
            for c = 1:length(conditions)
                cond = conditions{c};
                f_sep = sep_evns_connectivity_maps(f_subj_lock_band, cond, separation);

                load(sprintf('%s/%s', dpth, f_sep{1}), 'A')
                A_deck = zeros(size(A,1), size(A,2), length(f_sep));
                A_deck(:,:,1) = A;
                for f = 2:length(f_sep)
                    file = f_sep{f};
                    load(sprintf('%s/%s', dpth, file), 'A')
                    A_deck(:,:,f) = A;
                end

                if strcmp(separation,'ALL')
                    condition_nm = 'Average-All-events';
                else
                    condition_nm = sprintf('Average-%s-%s', separation, cond);
                end
                A_mean = mean(A_deck,3);
                save(sprintf('%s/%s_%s_%s_%s_average_%s_%s.mat', spth, subj, ref, lock, band, separation, cond), 'A_mean')
                
                plot_connectivity_map(A, subj, ref, lock, band, cmpth, loc, 'condition', condition_nm);

            end
        end
    end
end
