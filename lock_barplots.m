
df = readtable('all_OP_connections.xlsx');
plt_pth = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs/thesis/undirected_connectivity/plots/Stroop_CIC-CM/Average-ALL-OP/barplots';
[~,o] = sort(df.OP,'descend');
df = df(o,:);


subjs = {'sd09', 'sd10', 'sd14', 'sd18', 'sd19', 'sd21'};
locks = {'stim', 'resp'};
bands = {'HFB', 'LFP'};

connection_bins = zeros(1000,1000);
connections = {};
k = 0;


for s = 1:length(subjs)
    subj = subjs{s};
    df_subj = df(cellfun(@(x) strcmp(x, subj), df.Subj),:);
    for b = 1:length(bands)
        band = bands{b};
        df_band = df_subj(cellfun(@(x) strcmp(x, band), df_subj.Band),:);
%         if (strcmp(subj,'sd10') && strcmp(band,'HFB')) || (strcmp(subj,'sd21') && strcmp(band,'HFB')) || (strcmp(subj,'sd18') && strcmp(lock,'resp') && strcmp(band,'HFB')) || (strcmp(subj,'sd19') && strcmp(lock,'stim') && strcmp(band,'HFB'))
%             continue
%         end
        all_lock_ops = [];
        pairs = {};
        for n = 1:size(df_band,1)
            chan1 = df_band.R_Channel{n};
            chan2 = df_band.C_Channel{n};
            df_pair = df_band(cellfun(@(x,y) strcmp(x,chan1) & strcmp(y,chan2) | strcmp(x,chan2) & strcmp(y,chan1), df_band.R_Channel, df_band.C_Channel),:);
            if size(df_pair,1) < 2
                if strcmp(df_pair.Lock{1}, 'stim')
                    sub_lock = 'resp';
                else
                    sub_lock = 'stim';
                end
                df_sub = {subj, sub_lock, band, chan1, chan2, df_pair.R_Region, df_pair.C_Region, 0};
                df_pair = [df_pair; df_sub];
            end
            
            if find(strcmp(df_pair.Lock,'stim')) == 2
                df_pair = df_pair([2 1],:);
            end
            
            lock_ops = [df_pair.OP(1) df_pair.OP(2)];
            
            if sum(lock_ops) > 0 && diff(lock_ops) > 0
                pairs = [pairs; sprintf('%s -- %s', df_pair.R_Region{1}, df_pair.C_Region{1})];
                all_lock_ops = [all_lock_ops; lock_ops];
            end
            clearvars df_pair
        end



        h = figure('visible','off');
        barh(all_lock_ops)

        set(gca,'YTick',1:length(pairs))
        yticklabels(pairs)
        legend('SL', 'RL', 'location', 'northeastoutside')
        set(gca,'FontSize',24)
        set(gca,'FontWeight','bold')
        set(h, 'Units','pixels','Position',[983 597 1251 692])
        
        saveas(gca, sprintf('%s/%s_%s_OP.png',plt_pth,subj,band))
        
    end
end

