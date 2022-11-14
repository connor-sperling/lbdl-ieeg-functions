function network_verification2(direc_dir, xl_dir, study, ref, atlas, abr, condition_nm, ztol, binarize)

nboot = 50;
alpha = 0.05;
dthresh = 10;
zthresh = 1;

headers_all = {'Subj','Lock','Band','R_Channel','C_Channel','R_Region','C_Region','OP','PSOP_mean','min_OP','Percent_diff', 'New_Connection'};
sig_stats_table = cell(0,length(headers_all));
all_stats_table = cell(0,length(headers_all));

headers_conn = {'Connection','Number_of_instances','OP mean','OP variance','Difference mean','Difference variance'};
connection_table = cell(0,length(headers_conn));

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
%             if strcmp(subj, 'sd14') && strcmp(lock, 'resp') && strcmp(band, 'LFP')
%                 continue
%             end

            if abr % For connectivity maps
                xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
                loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
            else
                loc = [];
            end
            
            poststim_file = sprintf('%s_bipolar_%s_%s_adjaceny_%s.mat',subj,lock,band,condition_nm);
            load(sprintf('%s/%s', poststim_pth, poststim_file), 'A', 'evn', 'sig_lab')
            cutoff = 0.05;
            cutof_msk = A > cutoff;
            Apost = A.*cutof_msk;
            
            loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
            
            f_subj_lock_band = f_subj_lock(b == bands_num);
            f_subj_lock_band(cellfun(@(x) strcmp(x(1),'.'), f_subj_lock_band)) = [];
            if isempty(f_subj_lock_band)
                fprintf('\n%s %s %s not found\n', subj, lock, band)
                continue
            end
            
            file = f_subj_lock_band{1};
            load(sprintf('%s/%s', prestim_pth, file),'A')
            N = size(A,1);
            Apre = zeros(N,N,length(f_subj_lock_band));
            Apre(:,:,1) = A.*cutof_msk;
            for s = 2:length(f_subj_lock_band)
                file = f_subj_lock_band{s};
                load(sprintf('%s/%s', prestim_pth, file), 'A')
                Apre(:,:,s) = A.*cutof_msk;
            end
            
            
            
            Abm = zeros(N,N);
            Az = Abm;
            for i = 1:N
                for j = 1:i-1
                    apre_ij = squeeze(Apre(i,j,:));
                    apost_ij = Apost(i,j);
                    b_ij = [apre_ij;  bootstrp(nboot, @mean, apre_ij)];
                    [~, pv, ~, zv] = ztest(apost_ij, mean(b_ij), std(b_ij));
                    Abm(i,j) = mean(b_ij);
                    Az(i,j) = z_thresh(zv, pv, alpha);
%                     figure
%                     histogram(b_ij)
%                     hold on
%                     line([apost_ij apost_ij], [0 5], 'color', 'r')
%                     close
                end
            end
            
            Az_temp = Az;
            Az_temp(isinf(Az_temp)) = 0;
            [ri, ci] = find(isinf(Az));
            for u = 1:length(ri)
                if Az(ri(u), ci(u)) > 0 
                    Az(ri(u), ci(u)) = max(Az_temp(:));
                else
                    Az(ri(u), ci(u)) = min(Az_temp(:));
                end
            end
            
            
            
            Abm = Abm + Abm';
            Az = Az + Az';
            Az_thresh = Az.*(abs(Az) > zthresh);
            if sum(abs(Az_thresh(:))) > 0
                c1 = [.65 0;.83 .4; .4 .35]; % green
                c2 = [.28 1; .17 .77; .11 .49]; % copper
                c = cat(3,c1,c2);
                mtype = 'z-score';
                if binarize
                    mtype = sprintf('%s - Occurrence Probability', mtype);
                end
                barlab = 'z-score';
                plot_connectivity_map(Az_thresh, subj, ref, lock, band, plt_pth, loc, ztol, 'id', 'z-score', 'NV', [alpha,zthresh], 'maptype', mtype, 'barlab', barlab, 'color', c);
            else
                fprintf('\n\t No significant Az entries found: %s %s %s\n',subj,lock,band)
            end
            
            Ad = 100*(Apost - Abm)./Abm;
            Ad(isnan(Ad)) = 0;
            Ad_inf = isinf(Ad);
            Ad(Ad_inf) = 0;
            
            max_pchange = 1000;
            min_OP = 1/length(evn);
            if max(Ad(:)) > max_pchange
                [r,c] = find(Ad > max_pchange);
                for i = 1:length(r)
                    if Abm(r(i),c(i)) < min_OP
                        Ad(r(i),c(i)) = 0;
                        Ad_inf(r(i),c(i)) = true;
                    else
                        Ad(r(i),c(i)) = max_pchange;
                    end
                end
            end
            
            Ad_sig = Ad.*(Az ~= 0);
            Ad_sig_thresh = Ad_sig.*(abs(Ad_sig) > dthresh);
            if sum(abs(Ad_sig_thresh(:))) > 0
                c1 = [1 .5; .8 0; .2 0]; % red
                c2 = [.2 .27; .08 .7; .23 1]; % blue
                c = cat(3,c1,c2);
                mtype = 'Percent Difference (Post-Pre)';
                if binarize
                    mtype = sprintf('%s - Occurrence Probability', mtype);
                end
                barlab = '% difference';
                plot_connectivity_map(Ad_sig_thresh, subj, ref, lock, band, plt_pth, loc, ztol, 'id', 'difference', 'NV', [alpha,dthresh], 'maptype', mtype, 'barlab', barlab,'color',c);
            else
                fprintf('\n\t No significant Ad entries found: %s %s %s\n',subj,lock,band)
            end
            
            
            if sum(abs(Ad_inf(:))) > 0
                mtype = 'Post Only Connection';
                if binarize
                    mtype = sprintf('%s - Occurrence Probability', mtype);
                end
                plot_connectivity_map(Ad_inf, subj, ref, lock, band, plt_pth, loc, ztol, 'id', 'infty', 'NV', [alpha,zthresh], 'maptype', mtype);
            end
            
            chans = loc_subj.channel_organized;
            regions = loc_subj.region;
            for i = 1:N
                for j = 1:i-1
                    if Apost(i,j) > 0 && Ad_sig_thresh(i,j) ~= 0
                        sig_stats_table = [sig_stats_table; {subj,lock,band,chans{i},chans{j},regions{i},regions{j},100*Apost(i,j),100*Abm(i,j),min_OP,Ad_sig_thresh(i,j),Ad_inf(i,j)}];
                    end
                    all_stats_table = [all_stats_table; {subj,lock,band,chans{i},chans{j},regions{i},regions{j},100*Apost(i,j),100*Abm(i,j),min_OP,Ad_sig_thresh(i,j),Ad_inf(i,j)}];
                end
            end
%             
            

        end
            

        
    end
end
% 
% [uconns, u, uidx] = unique(cellfun(@(x,y) [x '_' y], sig_stats_table(:,6), sig_stats_table(:,7), 'uni', 0));
% OP = cell2mat(sig_stats_table(:,8));
% D = cell2mat(sig_stats_table(:,9));
% for ii = 1:length(uconns)
%     cmsk = uidx == ii;
%     uconn = uconns{ii};
%     OPm = mean(OP(cmsk));
%     OPv = var(OP(cmsk));
%     Dm = mean(D(cmsk));
%     Dv = var(D(cmsk));
%     lc = sum(cmsk);
%     connection_table = [connection_table; {uconn, lc, OPm, OPv, Dm, Dv}];
% end

sig_stats_table = cell2table(sig_stats_table, 'VariableNames', headers_all);
writetable(sig_stats_table, sprintf('%s/sig_connection_statistics.xlsx',plt_pth))

all_stats_table = cell2table(all_stats_table, 'VariableNames', headers_all);
writetable(all_stats_table, sprintf('%s/all_connection_statistics.xlsx',plt_pth))
% 
% connection_table = cell2table(connection_table, 'VariableNames', headers_conn);
% writetable(connection_table, sprintf('%s/connection_averages.xlsx',plt_pth))



end