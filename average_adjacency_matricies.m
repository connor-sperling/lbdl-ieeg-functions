function average_adjacency_matricies(direc_dir, subjs_dir, dtype, xl_dir, study, ref, atlas, abr, separation, conditions, ztol, binarize)


adj_type = sprintf('Average-%s',separation);
    
ddir = 'adjacency_matricies';
if binarize
    adj_type = sprintf('%s-OP',adj_type);
    ddir = sprintf('%s_binarized',ddir);
end
dpth = sprintf('%s/%s/%s/%s', direc_dir, dtype, study, ddir);
spth = sprintf('%s/%s/%s/%s', direc_dir, dtype, study, adj_type);

if strcmp(dtype,'data')
    plt=true;
    cmpth = sprintf('%s/plots/%s/%s', direc_dir, study, adj_type);
    cmpth_master = sprintf('%s/plots/%s/%s_master', direc_dir, study, adj_type);
else
    plt=true;
    cmpth = sprintf('%s/plots/%s/%s_surr', direc_dir, study, adj_type);
    cmpth_master = cmpth;
end


loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end

headers_all = {'Subj','Lock','Band','R_Channel','C_Channel','R_Region','C_Region','OP'};
OP_table = cell(0,length(headers_all));

files_sd = dir(sprintf('%s/sd*', dpth));
files_m = dir(sprintf('%s/m*', dpth));
files_sd = {files_sd.name};
files_m = {files_m.name};

if ~isempty(files_sd)
    all_files = files_sd;
else
    all_files = files_m;
end

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
            fprintf('\n%s %s %s\n', subj, lock, band)
            my_mkdir(spth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
            if plt
                my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
                my_mkdir(cmpth_master, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
            end
            
            tvd_file = sprintf('%s/%s/analysis/%s/%s/%s/ALL/TvD/%s/ALL_%s_TvD.mat', subjs_dir, subj, study, ref, lock, band, band);
            xl_nm = sprintf('significant_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
            xl_nm_gray = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
            
            
            f_subj_lock_band = f_subj_lock(b == bands_num);
            f_subj_lock_band(cellfun(@(x) strcmp(x(1),'.'), f_subj_lock_band)) = [];
            for s = 1:length(f_subj_lock_band)
                file = f_subj_lock_band{s};
                if binarize
                    file_nm = erase(file, '_binarized.mat');
                else
                    file_nm = erase(file, '.mat');
                end
                
                for c = 1:length(conditions)
                    cond = conditions{c};
                    condition_nm = sprintf('%s_%s', adj_type, cond);
                    if strcmp(condition_nm(end),'_')
                        condition_nm(end) = [];
                    end
                    
                    load(sprintf('%s/%s', dpth, file), 'A_deck','evn','sig_lab')
                    
                    load(tvd_file, 'TvD');
                    if strcmp(subj, 'sd14') 
                        TvD(cellfun(@(x) contains(x, 'RHB'), TvD(:,2)),:) = [];
                    end
                    real_sig_lab = TvD(:,2);
                    if isempty(real_sig_lab)
                        continue
                    end
                    
                    if abr % For connectivity maps
                        loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
                        loc_gray = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm_gray));
                    else
                        loc = [];
                    end
                    loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
                    if isempty(loc_subj)
                        continue
                    end
                    
                    mtype = sprintf('%s %s', separation, cond);
                    barlab = '';
                    if binarize
                        mtype = sprintf('%s %s', 'Occurrence Probability - ', mtype);
                        barlab = 'OP';
                    end

                    [A_deck_cond, evn_cond] = sep_evns_connectivity_maps(A_deck, evn, cond, separation);
                    A = mean(A_deck_cond,3); % Full deck of binary matrices -> averaged, OP matrix
                    evn_temp = evn;
                    evn = evn_cond;
                    
                    id_nm = 'OP';
                    if ~strcmp(separation, 'ALL')
                        id_nm = sprintf('%s_%s_%s',id_nm,separation,cond);
                    end
                    
                    % Generate 'master' OP maps (before they are trimmed)
                    if plt && ~isempty(A)
                        plot_connectivity_map(A, subj, ref, lock, band, cmpth_master, loc_gray, ztol, 'id', id_nm, 'maptype', mtype, 'barlab', barlab);
                    end
                    
                    sig_msk = ismember(sig_lab,real_sig_lab);
                    A = A(sig_msk, sig_msk); % Keeping only significant channels in OP matrix
                    
                    regions = loc_subj.region;
                    lab_ordered = loc_subj.channel_organized;
                    if length(lab_ordered) == length(real_sig_lab)
                        [~,order] = ismember(lab_ordered, real_sig_lab);
                        A = A(order,order);
                        real_sig_lab = real_sig_lab(order);
                    else
                        disp('Table and Data dimensions do not match')
                        continue
%                         error('Table and Data dimensions do not match')
                    end
                    
                    
                    
                    rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
                    region_only = cellfun(@(x) x{2}, rsplt, 'uni', 0);
                    wm_msk = cellfun(@(x) strcmp(x, 'WM') | strcmp(x, 'U') | strcmp(x, 'blanc') | strcmp(x, 'out'), region_only);

                    lab_ordered(wm_msk,:) = [];
                    regions(wm_msk,:) = [];
                    real_sig_lab(wm_msk,:) = [];
                    A = A(~wm_msk,~wm_msk); % Removing white matter channels from OP matrix
                    sig_lab = real_sig_lab;
                    
                    N = size(A,1);
                    
                    for i = 1:N
                        for j = 1:i-1
                            OP_table = [OP_table; {subj,lock,band,lab_ordered{i},lab_ordered{j},regions{i},regions{j},100*A(i,j)}];
                        end
                    end
            
                    if ~isempty(A)
                        save(sprintf('%s/%s_%s.mat', spth,file_nm,condition_nm),'A','evn','sig_lab')
                    end
                    evn = evn_temp;
                    
                    
                    
                    % Generate OP maps
                    if plt && ~isempty(A)
                        plot_connectivity_map(A, subj, ref, lock, band, cmpth, loc_gray, ztol, 'id', id_nm, 'maptype', mtype, 'barlab', barlab);
                    end
                end % conditions
            end % shifts
        end
    end
end

OP_table = cell2table(OP_table, 'VariableNames', headers_all);
writetable(OP_table, sprintf('%s/all_OP_connections.xlsx',spth))

end