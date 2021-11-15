function network_verification(ground_dir, dat_dir, study)

M = 10000;


prestim_pth = sprintf('%s/%s/Average-ALL-PoO', ground_dir, study);
poststim_pth = sprintf('%s/%s/Average-ALL-PoO', dat_dir, study);

files_sd = dir(sprintf('%s/sd*', poststim_pth));
files_m = dir(sprintf('%s/m*', poststim_pth));
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
%             my_mkdir(bdpth, sprintf('%s_%s_%s_%s_*',subj,ref,lock,band))
%             my_mkdir(dist_pth, sprintf('%s_%s_%s_%s_*',subj,ref,lock,band))

            f_subj_lock_band = f_subj_lock(b == bands_num);
            file = f_subj_lock_band{1};
            
            load(sprintf('%s/%s', prestim_pth, file), 'A')
            Apre = A;
            load(sprintf('%s/%s', poststim_pth, file), 'A')
            Apost = A;
            
            N = size(Apre,1);
            
            RMSE = zeros(M+1,6);
            RMSE(1) = norm(Apre-Apost,'fro')/N;
            k=0;
            for s= [1:5 11]
            % create surrogate maps
            for m = 1:M
                Surr = Apre;
                for j = 1:s
                    k=k+1;
                    swap = randi([1, N], 2, 1);
                    while any(abs(diff(swap)) == 0)
                        swap = randi([1, N], 2, 1);
                    end                    
                    r1 = Surr(swap(1),:);
                    r2 = Surr(swap(2),:);
                    Surr(swap(1),:) = r2; Surr(swap(2),:) = r1;
                    
                    c1 = Surr(:,swap(1));
                    c2 = Surr(:,swap(2));
                    Surr(:,swap(1)) = c2; Surr(:,swap(2)) = c1;
                end
                RMSE(m+1,k) = norm(Surr-Apost,'fro')/N;
            end
            
            end
%             figure; hold on
%             h = histogram(RMSE(2:end,1));
%             line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
%             ylim([0,2000])
%             title(sprintf('S = %i', s))
            figure;
            subplot(2,3,1)
            h = histogram(RMSE(2:end,1));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 1))
            subplot(2,3,2)
            h = histogram(RMSE(2:end,2));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 2))
            subplot(2,3,3)
            h = histogram(RMSE(2:end,3));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 3))
            subplot(2,3,4)
            h = histogram(RMSE(2:end,4));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 4))
            subplot(2,3,5)
            h = histogram(RMSE(2:end,5));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 5))
            subplot(2,3,6)
            h = histogram(RMSE(2:end,6));
            line([RMSE(1) RMSE(1)], [0 200], 'color', 'r', 'linewidth',2)
            ylim([0,2000])
            title(sprintf('S = %i', 11))
        end
            

        
    end
end




end