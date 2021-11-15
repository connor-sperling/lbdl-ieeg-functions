
df = readtable('sig_connection_statistics.xlsx');
[~,o] = sort(df.OP,'descend');
df = df(o,:);
% lin = 1:size(df,1);
% msk = logical(mod(lin,2));
% dfnrp = df(msk,:);
dfnrp = df;
% Region = cellfun(@(x,y) [x ' -- ' y], dfnrp.R_Region, dfnrp.C_Region,'uni',0);
dfnrp_new = table(dfnrp.Subj, dfnrp.Lock, dfnrp.Band, dfnrp.R_Region, dfnrp.C_Region, dfnrp.OP, dfnrp.PSOP_mean, dfnrp.Percent_diff);
dfnrp_new.Properties.VariableNames = {'Participant', 'Segmentation', 'Band', 'R_Region', 'C_Region', 'OP', 'PSOP', 'Percent_Difference'};

subjs = {'sd09', 'sd10', 'sd14', 'sd18', 'sd19', 'sd21'};
locks = {'stim', 'resp'};
bands = {'HFB', 'LFP'};

connection_bins = zeros(1000,1000);
connections = {};
k = 0;

lock_pds = [];
subj_band = {};
lock_reg = {};
for s = 1:length(subjs)
    subj = subjs{s};
    df_subj = dfnrp_new(cellfun(@(x) strcmp(x, subj), dfnrp_new.Participant),:);
    for l = 1:length(locks)
        lock = locks{l};
        T = get_lock_times(lock);
        df_lock = df_subj(cellfun(@(x) strcmp(x, lock), df_subj.Segmentation),:);
        for b = 1:length(bands)
            band = bands{b};
            df_band = df_lock(cellfun(@(x) strcmp(x, band), df_lock.Band),:);
            if (strcmp(subj,'sd10') && strcmp(band,'HFB')) || (strcmp(subj,'sd21') && strcmp(band,'HFB')) || (strcmp(subj,'sd18') && strcmp(lock,'resp') && strcmp(band,'HFB')) || (strcmp(subj,'sd19') && strcmp(lock,'stim') && strcmp(band,'HFB'))
                continue
            end
            fprintf('%s %s %s\n',subj,lock,band)
            [~,~,rnum] = unique(df_band.R_Region);
            t = table();
            for i = 1:max(rnum)
                rm = rnum==i;
                r_t = df_band(rm,:);
                [~,~,cnum] = unique(r_t.C_Region);
                for j = 1:max(cnum)
                    cm = cnum==j;
                    c_t = r_t(cm,:);
                    t = [t; c_t];
                end
            end
            
            t_resp = t(ismember(t.Segmentation,'resp'),:)
            t_stim = t(ismember(t.Segmentation,'stim'),:)
            for n = 1:size(t_resp,1)
                for m = 1:size(t_stim,1)
                    if strcmp(t_resp.R_Region{n}, t_stim.R_Region{m}) && strcmp(t_resp.C_Region{n}, t_stim.C_Region{m}) || strcmp(t_resp.R_Region{n}, t_stim.C_Region{m}) && strcmp(t_resp.C_Region{n}, t_stim.R_Region{m})
                        lock_reg = [lock_reg; sprintf('%s -- %s', t_resp.R_Region{n}, t_resp.C_Region{n})];
                        subj_band = [subj_band; {subj, band}];
                        lock_pds = [lock_pds; [t_resp.Percent_Difference, t_stim.Percent_Difference]];
                    end
                end
            end
     
            for n = 1:size(t,1)
                connection1 = sprintf('%s -- %s', t.R_Region{n}, t.C_Region{n});
                connection2 = sprintf('%s -- %s', t.C_Region{n}, t.R_Region{n});
                if strcmp(t.Segmentation,'resp')
                if ~ismember(connection1, connections) && ~ismember(connection2, connections)
                    k = k+1;
                    connections = [connections; connection1];
                    bin = connection_bins(:,k);
                    connection_bins(sum(bin~=0)+1,k) = t.Percent_Difference(n);
                elseif ismember(connection1, connections)
                    bidx = find(strcmp(connections,connection1));
                    bin = connection_bins(:,bidx);
                    connection_bins(sum(bin~=0)+1,bidx) = t.Percent_Difference(n);
                elseif ismember(connection2, connections)
                    bidx = find(strcmp(connections,connection2));
                    bin = connection_bins(:,bidx);
                    connection_bins(sum(bin~=0)+1,bidx) = t.Percent_Difference(n);
                end
                end
            end
            
            Region = cellfun(@(x,y) [x ' -- ' y], t.R_Region, t.C_Region,'uni',0);
            h = figure('visible','off');
            barh([t.OP,t.PSOP])
            
            if length(Region)>12
                xtickangle(90)
            else
                xtickangle(45)
            end
            set(gca,'XTick',1:length(Region))
            xticklabels(Region)
%             title(sprintf('Significant OP Connections With PSOP Mean: %s %s %s',subj,T.lock_abv,band),'FontSize',24)
            legend('OP', 'PSOP mean', 'location', 'northeastoutside')
            set(gca,'FontSize',24)
            set(gca,'FontWeight','bold')
            set(h, 'Units','pixels','Position',[983 859 1180 430])
            saveas(gca, sprintf('barplots/%s_%s_%s_sig_OP.png',subj,lock,band))
%             close
            
%             figure
%             scatter(t.PSOP, t.OP-)
%             title(sprintf('%s %s %s',subj,T.lock_abv,band))
        end
    end
end

figure
barh(lock_pds)
set(gca,'YTick',1:length(lock_reg))
yticklabels(lock_reg)

connection_bins(:,length(connections)+1:end) = [];
connection_bins(max(sum(connection_bins ~= 0))+1:end,:) = [];

nconnections = sum(connection_bins ~= 0);
sum_connection_bins = sum(connection_bins);
sum_connection_bins_avg = sum_connection_bins./nconnections;

[sum_sorted_connection_bins, ord] = sort(sum_connection_bins,'descend');
sorted_connections = connections(ord);
nconnections = nconnections(ord);

figure
barh(sum_sorted_connection_bins)
set(gca,'YTick',1:length(connections))
% xtickangle(90)
yticklabels(sorted_connections)
for jj = 1:length(sorted_connections)
%     if sum_sorted_connection_bins(jj) > 0
%         text(jj-.25, sum_sorted_connection_bins(jj)+15, num2str(nconnections(jj)));
%     else
%         text(jj-.25, sum_sorted_connection_bins(jj)-15, num2str(nconnections(jj)));
%     end
    if sum_sorted_connection_bins(jj) > 0
        text(sum_sorted_connection_bins(jj)+4, jj,  num2str(nconnections(jj)));
    else
        text(sum_sorted_connection_bins(jj)-4, jj, num2str(nconnections(jj)));
    end
end



