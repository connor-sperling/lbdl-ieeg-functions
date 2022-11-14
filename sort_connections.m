function sort_connections(direc_dir, xl_dir, dtype, adj_type, conditions, study, ztol, plt_study, atlas)

    dat_dir = sprintf('%s/%s/%s/%s',direc_dir,dtype,study,adj_type);
    plt_dir = sprintf('%s/plots/%s/%s',direc_dir,study,adj_type);
    
    files = dir(sprintf('%s/*.mat', dat_dir));
    files = {files.name};
    files(cellfun(@(x) strcmp(x(1),'.'), files)) = [];
    
    connections_xl = sprintf('%s/connections/%s/connections_%s.xlsx',direc_dir,study,adj_type);
    headers = {'Subj','Lock','Band','Condition','R_Channel','C_Channel','R_Region','C_Region','MNzW','Weight'};
%     if exist(connections_xl,'file')
%         connect_table = table2cell(readtable(connections_xl));
%     else
%         connect_table = cell(0,11);
%     end
    connect_table = cell(0,length(headers));

    study_dir = sprintf('%s/connections/%s',direc_dir,study);
    for c = 1:length(conditions)
        type_pth = sprintf('%s/%s_%s',study_dir,adj_type,conditions{c});
        my_mkdir(type_pth,'rmdir')
    end
        
    for ii = 1:length(files)
        adj_file = files{ii};
        load(sprintf('%s/%s', dat_dir, adj_file), 'A');
        
        adj_file_splt = strsplit(adj_file,'_');
        subj = adj_file_splt{1};
        ref = adj_file_splt{2};
        lock = adj_file_splt{3};
        band = adj_file_splt{4};
        adj_type = adj_file_splt{5};
        cond = erase(adj_file_splt{6},'.mat');
        cm_type  = sprintf('%s_%s',adj_type,cond);
%         cm_type = erase(adj_file_splt{5}, '.mat');
%         cond = erase(cm_type,sprintf('%s-',adj_type));
        
        cm_fig_file = sprintf('%s_map.fig', erase(adj_file, '.mat'));
        openfig(sprintf('%s/%s', plt_dir,cm_fig_file));
        
        xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
        loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
        loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
        
        N = size(A,1);
        Al = tril(A); Al = Al(:);
        mnzw = mean(Al(Al > ztol));
        for n = 1:N
            r_chan = loc_subj.channel_organized(n);
            r_region = loc_subj.region(n);
            for m = n+1:N
                c_chan = loc_subj.channel_organized(m);
                c_region = loc_subj.region(m);
                w = A(n,m);
                connect_table = [connect_table; {subj, lock, band, cond, r_chan, c_chan, r_region, c_region, mnzw, w}];
            end
        end
%         mnzw = sum(A(:))/(N*(N-1));
%         thresh = mnzw + 2*std(A(:));
%         
%         Al = tril(A);
%         idcs = find(Al >= thresh);
%         
%         r_idcs = mod(idcs, N);
%         r_idcs(r_idcs==0) = N;
%         c_idcs = ceil(idcs/N);
%         
%         r_chans = loc_subj.channel_organized(r_idcs);
%         r_regions = loc_subj.region(r_idcs);
%         
%         c_chans = loc_subj.channel_organized(c_idcs);
%         c_regions = loc_subj.region(c_idcs);
%         
%         % Moves or Makes 4 plots in each "connection" directory
%         for n = 1:length(idcs)
%             connect_dir = sprintf('%s/%s/%s_%s',study_dir,cm_type,r_regions{n},c_regions{n});
%             task_plt_dir = sprintf('%s/plots/%s/%s',direc_dir,plt_study,lock);
%             
%             r_plt_nm_orig = sprintf('%s_%s_%s_%s.png',subj,band,r_chans{n},ref);
%             c_plt_nm_orig = sprintf('%s_%s_%s_%s.png',subj,band,c_chans{n},ref);
%             r_plt_nm = sprintf('%s_%s_%s_%s_%s_r%i.png',subj,ref,lock,band,r_chans{n},r_idcs(n));
%             c_plt_nm = sprintf('%s_%s_%s_%s_%s_c%i.png',subj,ref,lock,band,c_chans{n},c_idcs(n));
%             
%             cm_nm = sprintf('%s.png', erase(cm_fig_file, '.fig'));
%             
%             my_mkdir(connect_dir, cm_nm, r_plt_nm, c_plt_nm)
%             
% %             plot_connected_electrodes(connect_dir, task_dat_dir, combined_plt_nm, {r_chans{n}, c_chans{n}}, {r_regions{n},c_regions{n}}, subj, lock, band)
%             copyfile(sprintf('%s/%s',task_plt_dir,r_plt_nm_orig), sprintf('%s/%s',connect_dir,r_plt_nm))
%             copyfile(sprintf('%s/%s',task_plt_dir,c_plt_nm_orig), sprintf('%s/%s',connect_dir,c_plt_nm))
%             saveas(gcf, sprintf('%s/%s',connect_dir,cm_nm))
%             
%             weight = Al(r_idcs(n), c_idcs(n));
%             rel_weight = (weight-mnzw)/mnzw;
%             
%             connect_table = [connect_table; {subj, lock, band, cond, r_chans{n}, c_chans{n}, r_regions{n}, c_regions{n}, thresh, mnzw, weight, rel_weight}];
%         end
    end

    
    connect_table = cell2table(connect_table, 'VariableNames', headers);
%     [~,ord] = sort(connect_table.Relative_Weight, 'descend');
%     connect_table = connect_table(ord,:);
    
    writetable(connect_table, connections_xl)

end