clc
clear
close all

% Two sources of iEEG data (SD, Marseille)
location = prompt('location');

% set appropriate path to Functions folder and subjects folder
if ispc
    addpath('L:/Functions/');
    subjs_dir = sprintf('L:/iEEG_%s/Subjs/', location);
elseif isunix
    addpath('/Volumes/LBDL_Extern/bdl-raw/Functions');
    subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs', location);
end


if strcmp(location,'San_Diego')
    fld_prefix = 'sd*';
    all_tasks = {'Naming', 'Stroop', 'VerbGen'};
else
    fld_prefix = 'pt*';
    all_tasks = {'DA', 'DV'};
end

% txto = 0;
% txtw = 0;

cd(subjs_dir)

% Grab all current subject directories
subjs = dir(fld_prefix);
subjs = {subjs.name};

% Select subjects
all_subjs = prompt('pick subjs', subjs);
all_subjs = strsplit(all_subjs);
an_subjs = {};

if strcmpi(all_subjs{1}, 'all')
    all_subjs = subjs;
end

% select study = <task>_<research name-subtype>
studies = prompt('pick study', all_tasks);
studies = strsplit(studies);


% Current supported frequency bands: HFB 70-150 Hz, LFP 0-30 Hz
all_bands = {'HFB', 'LFP'};

% Choose HFB, LFP or both to analyze
bands = prompt('pick band');
bands = strsplit(bands);

if strcmpi(bands{1}, 'both')
    bands = all_bands;
end

% Choose which type of reference to analyze: monopolar, bipolar
ref = prompt('reference');

typevn = prompt('ALL or condition');

winlen = input('\nSegment length?\n--> ');

delete_tfile = true;

for subjcell = all_subjs

 subj = char(subjcell);
    
    for studycell = studies
        
        studan = char(studycell);
        studsp = strsplit(studan, '_');
        task = studsp{1};
        rspl = strsplit(studsp{2}, '-');
        study = sprintf('%s_%s', task, rspl{1});
        
        studan_dir = sprintf('%s/%s/analysis/%s', subjs_dir, subj, studan);
        eeg_file = sprintf('%s/%s/data/%s_%s_%s_dat.mat', subjs_dir, subj, subj, study, ref);

        if ~exist(studan_dir, 'dir')
            continue
        else
            load(eeg_file)
        end
        
        for bndcell = bands
            
            band = char(bndcell);
            
            for lockcell = {'stim', 'resp'}
                
                lock = char(lockcell);
                
                tvd_pth = sprintf('%s/%s/analysis/%s/%s/%s/%s/TvD/%s', subjs_dir, subj, studan, ref, lock, typevn, band);
                
                tfile = sprintf('%s/txts/%s_average_%s_activity_by_%dms_segments.txt', subjs_dir, study, band, winlen);
                if delete_tfile
                    delete(tfile)
                    delete_tfile = false;
                end

                tvd_files = dir(sprintf('%s/*.mat', tvd_pth));
                tvd_files = {tvd_files.name};
                TvDm = [];
                for t = 1:length(tvd_files)
                    load(sprintf('%s/%s', tvdpth, tvd_files{t}))
                    TvDm = [TvDm; TvD];
                end
                txt4r(EEG, TvDm, winlen, dat_pth, subjs_dir, studan)

            end
        end
    end
end


