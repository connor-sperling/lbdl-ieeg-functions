ddir = 'Average-ALL-OP';
dpth = sprintf('%s/%s/%s/%s', direc_dir, 'data', study, ddir);




files_sd = dir(sprintf('%s/sd*', dpth));
files_m = dir(sprintf('%s/m*', dpth));
files_sd = {files_sd.name};
files_m = {files_m.name};

if ~isempty(files_sd)
    all_files = files_sd;
else
    all_files = files_m;
end
% 
% files_splt = cellfun(@(x) strsplit(x, '_'), all_files, 'uni', 0);
% [shift, ~, shift_num] = unique(cellfun(@(x) x{7}, files_splt, 'uni', 0));
% 
% for s = 1:length(shifts)
%     f_shift = all_files(s == shift_num);
% end
files_splt = cellfun(@(x) strsplit(x, '_'), all_files, 'uni', 0);
[subjs, ~, subjs_num] = unique(cellfun(@(x) x{1}, files_splt, 'uni', 0));

for p = 1:length(subjs) % loop thru patients
    subj = subjs{p};
    f_subj = all_files(p == subjs_num);
    f_subj_splt = cellfun(@(x) strsplit(x, '_'), f_subj, 'uni', 0);
    [locks, ~, locks_num] = unique(cellfun(@(x) x{3}, f_subj_splt, 'uni', 0));
    for l = 1:length(locks) % loop thru time locks
        lock = locks{l};
        f_subj_lock = f_subj(l == locks_num);
        f_subj_lock_splt = cellfun(@(x) strsplit(x, '_'), f_subj_lock, 'uni', 0);
        [bands, ~, bands_num] = unique(cellfun(@(x) x{4}, f_subj_lock_splt, 'uni', 0));
        for b = 1:length(bands) % loop thru frequency bands
            band = bands{b};
            
            f_subj_lock_band = f_subj_lock(b == bands_num);
            f_splt = cellfun(@(x) strsplit(x, '_'), f_subj_lock_band, 'uni', 0);
            evns = unique(cellfun(@(x) x{5}, f_splt, 'uni', 0));
            fprintf('\n%s %s %s %i\n', subj, lock, band, length(f_subj_lock_band)/length(evns))
            
        end
    end
end