

% MAKE SURE time_by_sigelec HAS BEEN RUN BEFORE RUNNING THIS

clear
close all

% San Diego
% subj = 'sd18';
% study = 'Stroop_CIC-CM';
% location = 'San_Diego';
% fs = 1024;
% xl_nm = 'stroop_loc_Desikan_Killiany_bipolar';

% Marseille
subj = 'pt20';
study = 'DA_GEN';
location = 'Marseille';
fs = 1000;
xl_nm = 'all_localization_6_9_20_29_bipolar';

lock = 'stim';
band = 'LFP';





subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs/',location);
dpth = sprintf('%s/%s/analysis/%s/bipolar/%s/ALL/data/%s/',subjs_dir,subj,study,lock,band);

load(sprintf('%s/%s_mean_sig_data.mat',dpth,subj), 'elecs_dat', 'lab')

T = get_lock_times([], lock);

% Convert to samples
an_st = round(abs(T.an_st-T.st)*fs/1000)+1;
an_en = round(abs(T.an_en-T.st)*fs/1000);
st_sam = round(T.st/1000*fs);
    
dat = elecs_dat(an_st:end,:);
rdim = 5;
nc = 3;

R = squareform(pdist(dat', 'correlation'));
datr = cmdscale(R,rdim)';


[latent, latent_mean] = paran(datr);
paran(datr)
ncomp = sum(latent > latent_mean);

[coeff,score,latent] = pca(dat,'NumComponents', nc);
[coeff_rot, T] = rotatefactors(coeff);
score_rot = score*T;

d = pdist(coeff_rot, 'correlation');
z = linkage(coeff_rot, 'complete', 'correlation');
I = inconsistent(z);
cutoff = median(I(:,end));
cluster_pos = cluster(z,'cutoff', cutoff, 'Criterion', 'distance');

% b = biplot(coeff_rot(:,1:2), 'Scores', score_rot(:,1:2));

h = dendrogram(z,0,'ColorThreshold',cutoff);
set(h,'LineWidth', 1.5)
line([0 size(z,1)+2], [cutoff cutoff], 'LineStyle', '--', 'linewidth', 1.5)

figure
silhouette(coeff_rot, cluster_pos, 'correlation')


loc_data = readtable(sprintf('%s/Excel Files/%s.xlsx',subjs_dir,xl_nm));
pt_loc_data = loc_data(cellfun(@(x) strcmp(x,subj), loc_data.subj),:);

datr2 = cmdscale(R,2)';
cscat = [];
cnums = [];

for i = 1:max(cluster_pos)
    msk = cluster_pos == i;
    
    cscat = [cscat datr2(:,msk)];
    cnums = [cnums sum(msk)];
    
    clab = lab(msk);
    cdat = elecs_dat(:, msk);
    M(:,i) = plot_clusters(cdat, lock, band, fs, i);
    
%     [~, chan_pos] = cellfun(@(x) ismember(x, pt_loc_data.SEEGChannel), clab);
%     clust_chan = pt_loc_data.SEEGChannel(chan_pos);
%     clust_loc = pt_loc_data.Localization(chan_pos);
%     m = sprintf('\nCluster %i\n\n  Channel    Localization\n ---------  --------------\n', i);
%     for c = 1:size(clust_loc,1)
%         m = sprintf('%s  %s    %s\n', m, clust_chan{c}, clust_loc{c});
%     end
%     
%     disp(m)
    
end

num_clusters = length(cnums);
clust_colors = [0.6027    0.8012    0.8852;...
                0.8800    0.8800    0.2600;...
                0.1879    0.2618    0.1178;...
                0.0772    0.1105    1.0000;...
                0.8364    0.0496    0.8612;...
                0.0033    0.9161    0.9405;...
                0.4500    0.8518    0.4000;...
                0.9327    0.6802    0.7199;...
                0.9000    0.6824    0.3631;...
                0.6659    0.0906    0.1160];

clr = clust_colors(randperm(10,num_clusters),:);
pmax = max(mean(M,2)+20);
pmin = min(mean(M,2)-10);
if pmin > 0
    pmin = -10;
end
tsamp = floor((T.an_st-T.st)*fs/1000)+1:floor((T.en-T.an_st)*fs/1000)+1;
tmesh = T.st:1000/fs:T.en;
datd = M(tsamp,:);
        
figure
hold on
xlim([T.st T.en])
ylim([pmin pmax])
for m = 1:size(M,2)
    plot(tmesh,M(:,m),'color',clr(m,:), 'linewidth', 1.5);
    plot([T.st     T.en], [0 0], 'k');
    plot([T.an_st  T.an_en], [0 0], 'k', 'LineWidth',2);
    plot([0 0] ,[pmin pmax], 'k', 'LineWidth', 2);
end

scatter_clusters(cscat, cnums, clr)

c = cophenet(z,d); disp(c)