
%% config
location = 'San_Diego';       % SD or Marseille
study = 'Stroop_CIC-CM';      % For now Stroop_CIC-CM are the only AR files that are set up for connectivity maps
fs = 1024;                    % Sampling rate, as always
atlas = 'Desikan_Killiany';   % For SD data - the atlas that was used for localization
xl_nm = 'stroop_loc';         % excel file that contains all of the localization for all of the sd stroop patients
ref = 'bipolar';              % always keep bipolar
bands = {'LFP', 'HFB'};  
locks = {'stim','resp'};
abr = true;                   % "annotate brain region" - directive to mark up connectivity maps with brain regions and red hemisphere lines
ztol = 0.001;                 % threshold for what is considered 0
dtype = 'data';               % Data type - either 'data' or 'surrogate'.


% input directory
if ispc
    addpath('L:/Functions/');
    subjs_dir = sprintf('L:/iEEG_%s/Subjs/', location);
elseif isunix
    addpath('/Volumes/LBDL_Extern/bdl-raw/Functions');
    subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs', location);
end

% output directory
if strcmp(study, 'Stroop_CIC-CM')
    direc_dir = sprintf('%s/thesis/undirected_connectivity',subjs_dir);    
else
    direc_dir = sprintf('%s/thesis/directed_connectivity/impulse_estimation',subjs_dir);
end

xl_dir = sprintf('%s/Excel Files', subjs_dir); % set path to excel directoy (in subjs folder)
stdsplt = strsplit(study, '_');
task = stdsplt{1}; % get task name (Stroop) from study name


%%



subjs = get_subjects();

for p = 1:length(subjs) % loop thru patients
subj = subjs{p}; 
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
    for lockc = locks % loop thru time locks (resp, stim)
        lock = char(lockc);
    for bandc = bands % loop thru frequency bands (HFB LFP)
        band = char(bandc);
        cmpth = sprintf('%s/thesis/undirected_connectivity/plots/%s/connectivity_maps', subjs_dir, study); % path for plotted connectivity maps
        dpth = sprintf('%s/thesis/undirected_connectivity/data/%s/adjacency_matricies', subjs_dir, study); % path for storing the connectivity map data
        
        % makes the directory if it does not exist, if already exists, only the
        % files named with the current subject AND lock AND band are
        % deleted
        my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        my_mkdir(dpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        
        dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band); % path to get the data created from iEEG_analysis
        cd(dat_dir) 
%         dfile = dir('*_GRAY.mat');
        dfile = dir('*.mat'); % gets all of the mat files from the 'dat_dir' directory
        dfile = {dfile.name}; % cleaning up
        dfile(cellfun(@(x) strcmp(x(1),'.'), dfile)) = []; % cleaning up
        file = dfile{1}; % cleaning up
        
        % evn_seg - 3d array of significant electrodes across all events
        %         - N x T x L
        %            - N = number of significant electrodes
        %            - T = 1000ms time window
        %            - L = number of events
        % evn     - names of all of the events
        % sig_lab - this is sort of a misnomer currently because all
        %           electodes are included in this list. The maps are
        %           currenly being made with all electrodes included
        load(file,'evn_seg','evn','sig_lab')
        
        