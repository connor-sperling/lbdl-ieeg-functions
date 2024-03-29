
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
% The name of the "study" gives the rest of the code a lot of
% information about how to analyze the dataset. "task" refers to
% the actual task that the subject performed, "researchname" refers
% to how the data was pre-processed - if error trials were rejected
% or not, if filler trials exist in the anaylzable data or not,
% etc. "subtype" exists to allow a pre-processed dataset to be
% analyzed in multiple ways without creating redundant data.
studies = prompt('pick study', all_tasks);
studies = strsplit(studies);


% Choose HFB, LFP or both to analyze: HFB 70-150 Hz, LFP 0-30 Hz
all_bands = {'HFB', 'LFP'};
bands = prompt('pick band');
bands = strsplit(bands);
if strcmpi(bands{1}, 'both')
    bands = all_bands;
end

% Choose which type of reference to analyze: monopolar, bipolar
ref = prompt('reference');


for subjcell = all_subjs % loop through selected subjects
    
    subj = char(subjcell);
    
    an_dir = sprintf('%s/%s/analysis', subjs_dir, subj); % analysis directory: for output files/plots
    df_dir = sprintf('%s/%s/data', subjs_dir, subj); % data files directory: for input/pre-processed data
    
    for studycell = studies % loop through selected studies

        cd(df_dir); % change directory to subject data files
        
        studan = char(studycell); % 'task_researchname-subtype
        stsplt = strsplit(studan, '_'); % {task} {researchname-subtype}
        task = stsplt{1}; % 'task'
        rspl = strsplit(stsplt{2}, '-'); % {researchname} {subtype}
        study = sprintf('%s_%s', task, rspl{1}); % 'task_researchname'
        
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
            
            for lockcell = {'stim','resp'}
                
                lock = char(lockcell);

                % Append the current frequency band and time lock to EEG struct
                EEG.band = band;
                EEG.lock = lock;

                % Create directories for data and plots
                lock_pth = sprintf('%s/%s/%s/%s', an_dir, studan, ref, lock);
                alldat_pth = sprintf('%s/ALL/data/%s', lock_pth, band);
                allplt_pth = sprintf('%s/ALL/plots/%s', lock_pth, band);
                alltvd_pth = sprintf('%s/ALL/TvD/%s', lock_pth, band);
                condat_pth = sprintf('%s/condition/data/%s', lock_pth, band);
                conplt_pth = sprintf('%s/condition/plots/%s', lock_pth, band);
                contvd_pth = sprintf('%s/condition/TvD/%s', lock_pth, band);
                plt_dir = sprintf('%s/plots/%s/%s', subjs_dir, studan, lock);

                % my_mkdir makes the directory if it does not exist and
                % deletes the contents of a specific file type if it does
                % exist. The latter is necessary so that data from a
                % certain channel does not remain in the directory after
                % analysis changes which then deems it not significant
                my_mkdir(alldat_pth, '*.mat')
                my_mkdir(allplt_pth, '*.png')
                my_mkdir(condat_pth, '*.mat')
                my_mkdir(conplt_pth, '*.png')
                my_mkdir(plt_dir, sprintf('%s_%s_*', subj, band))
                my_mkdir(alltvd_pth, '*.mat') 
                my_mkdir(contvd_pth, '*.mat')

                prompt('processing info', subj, task, band, lock, size(EEG.data,1), length(evn), length(raw_evn))


                % Different anaylsis techniques for different tasks/studies
                switch studan

                    case 'Naming_CSIE'
                        idepa = 0;
                        cmat = [119, 68, 0; 155, 118, 16; 171, 148, 57;...
                                202, 181,70;213, 222, 92; 234, 243, 104];
                        naming_analysis(EEG, studan, lock_pth, cmat)
                        
                    case 'Naming_HLD'
                        analyze_events_by_condition(EEG, 'Den', {'HD', 'LD'}, lock_pth, studan) 

                    case 'Naming_ERRAN'
                        cmat = [0,   85,  196;...
                                210, 180, 126]./255;
                        analyze_events_by_condition(EEG, 'ErrC', {'0-1', '1-0'}, lock_pth, studan, cmat) 

                    case 'Stroop_EA-error'
                        cmat = [0,   85,  196;...
                                210, 180, 126]./255;
                        analyze_events_by_condition(EEG, 'ErrC', {'-1-0', '-0-1'}, lock_pth, studan, cmat) 

                    case 'Stroop_EA-congruency' % 7/31 - Spatial stroop C vs. I
                        cmat = [0,   85,  196;...
                                166, 205, 255;...
                                210, 180, 126;...
                                124, 81,  8]./255;
%                         cmat = [0,   85,  196;...
%                                 210, 180, 126]./255;
                        analyze_events_by_condition(EEG, 'Cong', {'C-C', 'C-I', 'I-C', 'I-I'}, lock_pth, studan, cmat);
%                         events_by_condition_modular(EEG, lock_pth, studan, '*-*-*-x-*-*', {'Cong_Space', 'Incong_Space'}, cmat);
                        

                    case 'Stroop_EA'
                        % For connectivity maps
%                         segment_events_per_channel(EEG, {EEG.analysis.type}' , [EEG.analysis.latency]', [EEG.analysis.resp]', alldat, 'ALL') 
%                         TvD = sig_freq_band(EEG, [EEG.analysis.resp]', sprintf('%s/ALL', lock_pth), 'ALL');
%                         segment_channels_per_event(EEG, TvD, condat, 'allChanPerEvn')
                        
                        % Beta testing new significance tests
                        evn = {EEG.analysis.type}';
                        evn_idc = [EEG.analysis.latency]';
                        rtm = [EEG.analysis.resp]';
                        segment_events_per_channel(EEG, evn, evn_idc, rtm, alldat_pth, 'ALL') 
                        TvD = sig_freq_band(EEG, rtm, sprintf('%s/ALL', lock_pth), 'ALL');
%                         eielectrode_psd(EEG, evn, evn_idc, rtm, chan_power_dat_pth, 'ALL')
                        
                        
                    case 'Stroop_CIC-CM'
                        filter_data = true;
                        ztol = 0.001;
                        segment_channels_per_event(EEG, {}, condat_pth, 'allChanPerEvn', filter_data)
                        generate_connectivity_maps_iEa(EEG, subjs_dir, condat_pth, study, ztol)
                        
                        segment_events_per_channel(EEG, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', lock_pth), 'ALL');
                        
                        
                    case 'Stroop_CIC-CM-surrogate'
                        alt_study = 'Stroop_CIC-CM';
                        alltvd_pth = sprintf('%s/%s/%s/%s/ALL/TvD/%s/ALL_%s_TvD.mat', an_dir, alt_study, ref, lock, band, band);
                        load(alltvd_pth, 'TvD')
                        filter_data = true;
                        segment_channels_per_event_surrogate(EEG, TvD, condat_pth, filter_data)
                            
                        
                    case 'Stroop_CIC-MISO'
                        segment_events_per_channel(EEG, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', lock_pth), 'ALL');
                        
                        filter_data = false;
                        segment_channels_per_event(EEG, TvD, condat_pth, 'allChanPerEvn', filter_data)
                        
                        
                    case 'Stroop_CIC-congruency'
%                         cmat = [0,   85,  196;...
%                                 166, 205, 255;...
%                                 210, 180, 126;...
%                                 124, 81,  8]./255;
%                             
                        cmat = [0,   85,  196;...
                                210, 180, 126]./255;
                        stroop_task_congruency_analysis(EEG, studan, lock_pth, cmat) 
                        
                    case 'Stroop_CIC-NR'
                        stroop_NR_analysis(EEG, studan, lock_pth)

                    case 'Stroop_CIC-R'
                        stroop_R_analysis(EEG, studan, lock_pth)

                    case 'DA_GEN'
                        segment_events_per_channel(EEG, evn, evn_idc, rtm, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, rtm, sprintf('%s/ALL', lock_pth), 'ALL');
%                         plot_DA_DV(EEG, study)

                    case 'DV_GEN'
                        segment_events_per_channel(EEG, evn, evn_idc, rtm, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, rtm, sprintf('%s/ALL', lock_pth), 'ALL');
%                         plot_DA_DV(EEG, study)

                    case 'DA_GEN-CM'
                        segment_events_per_channel(EEG, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', lock_pth), 'ALL');
                        segment_channels_per_event(EEG, TvD, condat_pth, 'allChanPerEvn')
                        
                    case 'DV_GEN-CM'
                        segment_events_per_channel(EEG, alldat_pth, 'ALL') 
                        TvD = significant_electrode_zscore(EEG, sprintf('%s/ALL', lock_pth), 'ALL');
                        segment_channels_per_event(EEG, TvD, condat_pth, 'allChanPerEvn')
                        
                end
            end       
        end    
    end  
end















