
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

cd(subjs_dir)

% Grab all current subject directories
subjs = dir(fld_prefix);
subjs = {subjs.name};

% Select subjects
all_subjs = prompt('pick subjs', subjs);
all_subjs = strsplit(all_subjs);

if strcmpi(all_subjs{1}, 'all')
    all_subjs = subjs; 
end

% select study = <task>_<research name-subtype>
studies = prompt('pick study', all_tasks);
studies = strsplit(studies);

idepa = prompt('study condition');

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



for subjcell = all_subjs
    
    subj = char(subjcell);
    
    an_dir = sprintf('%s/%s/analysis', subjs_dir, subj);
    df_dir = sprintf('%s/%s/data', subjs_dir, subj); 
    
    for studycell = studies

        cd(df_dir);
        
        studan = char(studycell);
        studsp = strsplit(studan, '_');
        task = studsp{1};
        rspl = strsplit(studsp{2}, '-');
        study = sprintf('%s_%s', task, rspl{1});
        
        eeg_file = sprintf('%s_%s_%s_dat.mat', subj, study, ref);
        
        sdata = dir(df_dir);
        sdata = {sdata.name};
        
        % if eeg_file exists in subject data directory, it will load and
        % carry out the analysis, it will skip this file otherwise
        if ~ismember(eeg_file, sdata)
            continue
        else
            load(eeg_file, 'EEG')
            raw_evn = {EEG.event.type}';
            rtm = [EEG.analysis.resp]';
            evn = {EEG.analysis.type}';
            evn_idc = [EEG.analysis.latency]';
        end
        
        for bndcell = bands
            
            band = char(bndcell);
            
            for lockcell = {'stim', 'resp'}
                
                lock = char(lockcell);

                % Append the current frequency band and time lock to EEG struct
                EEG.band = band;
                EEG.lock = lock;

                % Create directories for data and plots
                lock_pth = sprintf('%s/%s/%s/%s', an_dir, studan, ref, lock);
                alldat = sprintf('%s/ALL/data/%s', lock_pth, band);
                allplt = sprintf('%s/ALL/plots/%s', lock_pth, band);
                alltvd = sprintf('%s/ALL/TvD/%s', lock_pth, band);
                condat = sprintf('%s/condition/data/%s', lock_pth, band);
                conplt = sprintf('%s/condition/plots/%s', lock_pth, band);
                contvd = sprintf('%s/condition/TvD/%s', lock_pth, band);
                aplt = sprintf('%s/plots/%s/%s', subjs_dir, studan, lock);

                % my_mkdir makes the directory if it does not exist and
                % deletes the contents of a specific file type if it does
                % exist. The latter is necessary so that data from a
                % certain channel does not remain in the directory after
                % analysis changes which then deems it not significant
                my_mkdir(alldat, '*.mat', allplt, '*.png')
                my_mkdir(condat, '*.mat', conplt, '*.png')
                my_mkdir(aplt, sprintf('%s_%s_*', subj, band))
                my_mkdir(alltvd, '*.mat') 
                my_mkdir(contvd, '*.mat')

                prompt('processing info', subj, task, band, lock, size(EEG.data,1), length(evn), length(raw_evn))


                % Different anaylsis techniques for different tasks/studies
                switch studan

                    case 'Naming_CSIE'
                        idepa = 0;
                        cmat = [119 68 0;155, 118, 16;171, 148,57; 202, 181,70;213, 222, 92;234, 243, 104];
                        naming_analysis(EEG, studan, lock_pth, cmat)

                    case 'Naming_HLD'
                        events_by_condition(EEG, 'Den', {'HD', 'LD'}, lock_pth, studan, idepa) 

                    case 'Naming_ERRAN'
                        events_by_condition(EEG, 'ErrC', {'0', '1'}, lock_pth, studan, idepa) 

                    case 'Stroop_EA-error'
                        cmat = [0,   85,  196;...
                                210, 180, 126]./255;
                        events_by_condition(EEG, 'ErrC', {'-1-0', '-0-1'}, lock_pth, studan, idepa, cmat) 

                    case 'Stroop_EA-congruency'
                        idepa = 0;
                        cmat = [0,   85,  196;...
                                166, 205, 255;...
                                210, 180, 126;...
                                124, 81,  8]./255;
                        events_by_condition(EEG, 'Cong', {'C-C', 'C-I', 'I-C', 'I-I'}, lock_pth, studan, idepa, cmat);

                    case 'Stroop_EA'
                        channel_by_event(EEG, {EEG.analysis.type}' , [EEG.analysis.latency]', [EEG.analysis.resp]', alldat, 'ALL') 
                        TvD = sig_freq_band(EEG, [EEG.analysis.resp]', sprintf('%s/ALL', lock_pth), 'ALL');
                        stim_segmentation(EEG, TvD, condat, 'allChanPerEvn')

                    case 'Stroop_CIC-NR'
                        idepa = 0;
                        stroop_NR_analysis(EEG, studan, lock_pth)

                    case 'Stroop_CIC-R'
                        idepa = 0;
                        stroop_R_analysis(EEG, studan, lock_pth)

                    case 'DA_GEN'
                        channel_by_event(EEG, evn, evn_idc, rtm, alldat, 'ALL') 
                        TvD = sig_freq_band(EEG, rtm, sprintf('%s/ALL', lock_pth), 'ALL');

                    case 'DV_GEN'
                        channel_by_event(EEG, evn, evn_idc, rtm, alldat, 'ALL') 
                        TvD = sig_freq_band(EEG, rtm, sprintf('%s/ALL', lock_pth), 'ALL');
                end
            end       
        end    
    end  
end















