function all_op(direc_dir, xl_dir, study, ref, atlas, abr, condition_nm, ztol, binarize)

nboot = 200;
alpha = 0.05;
dthresh = 10;
zthresh = 1;

headers_all = {'Subj','Lock','Band','R_Channel','C_Channel','R_Region','C_Region','OP'};
all_op = cell(0,length(headers_all));


prestim_pth = sprintf('%s/surrogate/%s/%s', direc_dir, study, condition_nm);
poststim_pth = sprintf('%s/data/%s/%s', direc_dir, study, condition_nm);
plt_pth = sprintf('%s/plots/%s/NV_%s', direc_dir, study, condition_nm);

files_sd = dir(sprintf('%s/sd*', prestim_pth));
files_m = dir(sprintf('%s/m*', prestim_pth));
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
            my_mkdir(plt_pth, sprintf('%s_%s_%s_%s_*',subj,ref,lock,band))

            if abr % For connectivity maps
                xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
                loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
            else
                loc = [];
            end
            
            poststim_file = sprintf('%s_bipolar_%s_%s_adjaceny_%s.mat',subj,lock,band,condition_nm);
            load(sprintf('%s/%s', poststim_pth, poststim_file), 'A')
           
            Apost = A*100;
            N = size(Apost,1);
            loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
           
            
            chans = loc_subj.channel_organized;
            regions = loc_subj.region;
            for i = 1:N
                for j = 1:i-1
                    if Apost(i,j) > 0
                        all_op = [all_op; {subj,lock,band,chans{i},chans{j},regions{i},regions{j},Apost(i,j)}];
                    end
                end
            end
%             
            

        end
            

        
    end
end


all_op = cell2table(all_op, 'VariableNames', headers_all);
writetable(all_op, sprintf('%s/all_op.xlsx',plt_pth))


end