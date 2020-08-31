
clear
close all
clc

% Processing stream for grouping electrodes by brain region and/or
% clustering by data signiture in order to create connectivity maps.

%% Initialize variables

% San Diego
% location = 'San_Diego';
% study = 'Stroop_CIC-CM';
% fs = 1024;
% atlas = 'Desikan_Killiany'; % For SD data
% xl_nm = 'stroop_loc';

% Marseille
location = 'Marseille';
study = 'DA_GEN-CM';
fs = 1000;
atlas = 'Region';
xl_nm = 'all_localization_6_9_20_29';

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

%% Localization files

xl_bip_nm = bipolar_reference_loc_data(xl_dir, xl_nm, atlas);

% currently only works with bipolar referenced loc data
write_significant_localization_table(subjs_dir, xl_bip_nm, atlas, study, ref, locks, bands)


%% Reorder data

reorder_channel_by_time_data(subjs_dir, study, ref, locks, bands)


%% Generate Connectivity Maps

abr = true; % "annotate brain region"
generate_connectivity_maps(subjs_dir, study, ref, locks, bands, atlas, abr)