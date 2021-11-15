
df_sig = readtable('sig_connection_statistics.xlsx');
df_all = readtable('all_connection_statistics.xlsx');

[~,o] = sort(df_sig.OP,'descend');
df_sig = df_sig(o,:);


subjs = {'sd09', 'sd10', 'sd14', 'sd18', 'sd19', 'sd21'};
locks = {'stim', 'resp'};
bands = {'HFB', 'LFP'};

connection_bins = zeros(1000,1000);
connections = {};
k = 0;

lock_pds = [];
pairs = {};
for s = 1:length(subjs)
    subj = subjs{s};
    df_sig_subj = df_sig(cellfun(@(x) strcmp(x, subj), df_sig.Subj),:);
    df_all_subj = df_all(cellfun(@(x) strcmp(x, subj), df_all.Subj),:);
    for b = 1:length(bands)
        band = bands{b};
        df_sig_band = df_sig_subj(cellfun(@(x) strcmp(x, band), df_sig_subj.Band),:);
        df_all_band = df_all_subj(cellfun(@(x) strcmp(x, band), df_all_subj.Band),:);
        if (strcmp(subj,'sd10') && strcmp(band,'HFB')) || (strcmp(subj,'sd21') && strcmp(band,'HFB')) || (strcmp(subj,'sd18') && strcmp(lock,'resp') && strcmp(band,'HFB')) || (strcmp(subj,'sd19') && strcmp(lock,'stim') && strcmp(band,'HFB'))
            continue
        end
        
        for n = 1:size(df_sig_band,1)
            chan1 = df_sig_band.R_Channel{n};
            chan2 = df_sig_band.C_Channel{n};
            df_pair = df_sig_band(cellfun(@(x,y) strcmp(x,chan1) & strcmp(y,chan2) | strcmp(x,chan2) & strcmp(y,chan1), df_sig_band.R_Channel, df_sig_band.C_Channel),:);
            if size(df_pair,1) < 2
                if strcmp(df_pair.Lock{1}, 'stim')
                    sub_lock = 'resp';
                else
                    sub_lock = 'stim';
                end
                df_sub = df_all_band(cellfun(@(x,y,z) strcmp(z,sub_lock) & (strcmp(x,chan1) & strcmp(y,chan2) | strcmp(x,chan2) & strcmp(y,chan1)), df_all_band.R_Channel, df_all_band.C_Channel, df_all_band.Lock), :);
                if isempty(df_sub)
                    df_sub = {subj, sub_lock, band, chan1, chan2, df_pair.R_Region, df_pair.C_Region, 0, df_pair.PSOP_mean, 0, 0, false};
                else
                    d=1;
                end
                df_pair = [df_pair; df_sub];
            end
            
            if find(strcmp(df_pair.Lock,'stim')) == 2
                df_pair = df_pair([2 1],:);
            end
            
            pairs = [pairs; sprintf('%s -- %s', df_pair.R_Region{1}, df_pair.C_Region{1})];
            lock_pds = [lock_pds; [df_pair.OP(1) df_pair.OP(2) df_pair.PSOP_mean(1)]];
            clearvars df_pair
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



