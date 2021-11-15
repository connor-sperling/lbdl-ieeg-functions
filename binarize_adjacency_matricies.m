function binarize_adjacency_matricies(direc_dir, dtype, study, ztol, ref)

dpth = sprintf('%s/%s/%s/adjacency_matricies', direc_dir, dtype, study);
bdpth = sprintf('%s/%s/%s/adjacency_matricies_binarized', direc_dir, dtype, study);
dist_pth = sprintf('%s/distributions/%s/binarization_threshold', direc_dir, study);

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
        T = get_lock_times(lock);
        f_subj_lock = f_subj(l == locks_num);
        f_subj_lock_splt = cellfun(@(x) strsplit(x, '_'), f_subj_lock, 'uni', 0);
        [bands, ~, bands_num] = unique(cellfun(@(x) x{4}, f_subj_lock_splt, 'uni', 0));
        for b = 1:length(bands) % loop thru frequency bands
            band = bands{b};
            fprintf('\n%s %s %s\n', subj, lock, band)
            my_mkdir(bdpth, sprintf('%s_%s_%s_%s_*',subj,ref,lock,band))
%             my_mkdir(dist_pth, sprintf('%s_%s_%s_%s_*',subj,ref,lock,band))
            
            
            f_subj_lock_band = f_subj_lock(b == bands_num);
            f_subj_lock_band(cellfun(@(x) strcmp(x(1),'.'), f_subj_lock_band)) = [];
            for n = 1:length(f_subj_lock_band)
                file = f_subj_lock_band{n};
                file_nm = erase(file, '.mat');
                load(sprintf('%s/%s', dpth, file), 'A_deck','evn','sig_lab')
            
                A_deck_n = A_deck./max(A_deck(:));
                weights = A_deck_n(:);
                weights_nz = weights(weights > ztol);

                 % Plot the Nonzero weight histogram with threshold displayed
    %             figure('visible','off')
    %             hold on
    %             h = histogram(weights_nz);
    %             maxplot = max(h.Values)+mean(h.Values);
    %             ylim([0,maxplot])
    %             
    %             counts = h.BinCounts; nomax_counts = counts;
    %             edges = h.BinEdges;
    %             thresh = h.BinEdges(h.BinCounts == max(h.BinCounts(h.BinEdges(2:end) > mean(weights_nz))));
    %             thresh = edges(counts == max(counts));
    %             if mean(weights_nz) > 0.2
    %                 thresh = 0.2;
    %             else
    %                 thresh = mean(weights_nz);
    %             end
                thresh = .05;
    %             line([thresh thresh], [0 maxplot],'color','r','linewidth',1.5)
    %             text(1.2*thresh, mean([max(h.Values) maxplot]),sprintf('T = %.3f',thresh))
    %             title(sprintf('Distribution of Nonzero Weights for %s %s %s events',subj,T.lock_abv,band))
    %             ylabel('Count')

                A_deck = double(A_deck_n > thresh);
                save(sprintf('%s/%s_binarized.mat', bdpth, file_nm),'A_deck','evn','sig_lab')
            end
            
%             saveas(gca, sprintf('%s/%s_%s_%s_%s_nonzero_weight_dist.png',dist_pth,subj,ref,lock,band))
%             close
            
           
        end
    end
end
