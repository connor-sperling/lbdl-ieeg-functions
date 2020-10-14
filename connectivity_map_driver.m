
clear
close all
clc

% Processing stream for grouping electrodes by brain region and/or
% clustering by data signiture in order to create connectivity maps.

%% Initialize variables

% San Diego
location = 'San_Diego';
study = 'Stroop_CIC-CM';
fs = 1024;
atlas = 'Desikan_Killiany'; % For SD data
xl_nm = 'stroop_loc';

% Marseille
% location = 'Marseille';
% study = 'DA_GEN-CM';
% fs = 1000;
% atlas = 'Region';
% xl_nm = 'all_localization_6_9_20_29';

ref = 'bipolar';
bands = {'LFP', 'HFB'};
locks = {'stim','resp'};

if ispc
    addpath('L:/Functions/');
    subjs_dir = sprintf('L:/iEEG_%s/Subjs/', location);
elseif isunix
    addpath('/Volumes/LBDL_Extern/bdl-raw/Functions');
    subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs', location);
end

xl_dir = sprintf('%s/Excel Files', subjs_dir);
stdsplt = strsplit(study, '_');
task = stdsplt{1};

abr = true; % "annotate brain region"

%% Localization files

xl_bip_nm = bipolar_reference_loc_data(xl_dir, xl_nm, atlas);

% currently only works with bipolar referenced loc data
write_significant_localization_table(subjs_dir, xl_bip_nm, atlas, study, ref, locks, bands)


%% Reorder data

reorder_channel_by_time_data(subjs_dir, study, ref, locks, bands)


%% Remove white-matter/unknown

remove_white_matter_channels(subjs_dir, atlas, study, ref, locks, bands)

%% Choose AR order for each data
if contains(xl_dir, 'San_Diego')
    subjs = dir(sprintf('%s/sd*', subjs_dir));
else
    subjs = dir(sprintf('%s/pt*', subjs_dir));
end
subjs = {subjs.name};

sARo = [];
for p = 1:length(subjs) % loop thru patients
    subj = subjs{p};
    stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
    ARo = [];
    if exist(stddir, 'dir')
    for l = 1:length(locks)
        for b = 1:length(bands)
            aic_ar(location, subj, study, ref, locks{l}, bands{b}, fs)
            aro_m = sprintf('\nChoose AR order for %s, %s, %s, %s: ', subj, ref, locks{l}, bands{b});
            aro = input(aro_m);
            ARo = [ARo aro];
            close all
        end
    end
    sARo = [sARo; ARo];
    end
end


%% Generate Connectivity Maps

generate_connectivity_maps(subjs_dir, study, ref, locks, bands, atlas, abr)

%% Mean maps - ALL

separation = 'ALL';
conditions = {''};
average_adjacency_matricies(subjs_dir, study, ref, atlas, abr, separation, conditions)


%% Mean maps - condition

separation = 'TaskCongruency';
conditions = {'C','I'};
average_adjacency_matricies(subjs_dir, study, ref, atlas, abr, separation, conditions)

