%%
%   A user friendly command line interface program for loading iEEG data
%   and preparing data for further analysis.
%   User mays
%       - Load iEEG data that may be stored in a variety of formats
%       - Annotate data by patient, patient task, reference type, etc.
%       - Trim large amounts of unnecessary data for faster anaylsis
%       - Find the indicies of Stimuls Onset events from subject task
%       - Remove superfluous electrode channels data
%       - Remove noisy or damaged channels from data
%       - Reject Stimulus events based on known errors or noisy data
%       - Notch filter line noise from data
%       - Save all data, progress and annotations
%
%
%   VARIABLE GUIDE:
%
%       PATH VARIABLES:
%
%           pth - path to the subject directory (./Subjs/"SUBID"/)
%           df_dir - path to the ./Subjs/"SUBID"/Data Files directory
%   
%  
%       SUBJECT/TASK VARIABLES:
%
%           SUBID - subject ID (i.e. SD16)
%           task - task code name (i.e Naming)
%
%        
%       OUTPUT FILES           
%           
%           gdat_r - all good electrode matrix (Channel x Time), in bipolar
%                    unipolar format
%           glab_r - channel labels corresponding to good channel data
%           EEG - Contains all necessary information about the iEEG
%                 recording in structure format including gdat_r and glab_r
%
%
%       AUXILIARY SCRIPTS
%           
%           frequency_band_analysis
%           event_prep
%           sig_freq_band
%           naming_analysis
%           stroop_analysis 
% 
%           plot_naming
%           plot_stroop
%           subplot_all
%           shade_plot
%           rgb_grad 
% 
%           bipolar_referencing
%           event_locator
%           remove_channels
%           make_EEG
% 
%           loadbar
%           prompt
%           usr_yn
% 
%
%       OUTSIDE SCRIPTS & PACKAGES USED
%
%           eeglab
%           edfread

%% Define subject & set paths

warning('off')
% close all
clearvars -except Rec Hdr EEG EEGr
clc

location = prompt('location');

if ispc
    addpath('L:/Functions/');
    subjs_dir = sprintf('L:/iEEG_%s/Subjs/', location);
elseif isunix
    addpath('/Volumes/LBDL_Extern/bdl-raw/Functions');
    addpath('/Users/connor-home/MATLAB/eeglab2019_0')
    subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs', location);
end

cd(subjs_dir)

d = dir;
pts = {d.name};
pts = pts(cellfun(@(x) contains(x,'sd') || contains(x,'pt'), pts));

subj = prompt('define subject', subjs_dir, pts, location);

pth = sprintf('%s/%s', subjs_dir, subj);

% assigns data directory
df_dir = sprintf('%s/Data Files/', pth);                  
   

%% Choose and load data

cd(df_dir);

rec_files = dir('*REC.mat');
hdr_files = dir('*HDR.mat');
eeg_files = dir('*dat.mat');
edf_files = dir('*.EDF');
full_files = [{rec_files.name} {eeg_files.name} {edf_files.name}];
rec_files = char({rec_files.name});
hdr_files = char({hdr_files.name});
eeg_files = char({eeg_files.name});
full_files = char(full_files);

% Files found in df_dir are written to lists (rec_files, etc.). If it
% didnt find any files, warning is thrown and user has option to place
% files in df_dir
if isempty(full_files) || size(hdr_files,1) ~= size(rec_files,1)
    while true
        [ufile,upath] = uigetfile;
        if isequal(ufile, 0)
            if user_yn('exit prog? 1')
                return
            end
        elseif contains(ufile, 'REC.mat')
            load([upath erase(ufile,'REC.mat') 'HDR.mat']);
            load([upath ufile]);
            eeg = false;
            break
        elseif contains(ufile, '.EDF') || contains(ufile, '.edf')
            [Hdr, Rec] = edfread([upath ufile]);
            save([df_dir erase(ufile, ".EDF") 'REC.mat'], 'Rec', '-v7.3');
            save([df_dir erase(ufile, ".EDF") 'HDR.mat'], 'Hdr');    
            break
        end
    end
else
    file_idx = prompt('choose file', full_files);
end


% Option to load in file. Saves user time if file already exists in ws
fname = strtrim(full_files(file_idx,:));
if user_yn('load file?')
    if contains(full_files(file_idx,:),'REC')
        load([strtrim(erase(full_files(file_idx,:),'REC.mat')) 'HDR.mat']);
        load(fname);
    elseif contains(full_files(file_idx,:),'edf') || contains(full_files(file_idx,:),'EDF')
        [Hdr, Rec] = edfread(fname);
        save([df_dir strtrim(erase(full_files(file_idx,:), ".EDF")) 'REC.mat'], 'Rec', '-v7.3');
        save([df_dir strtrim(erase(full_files(file_idx,:), ".EDF")) 'HDR.mat'], 'Hdr');
    elseif contains(full_files(file_idx,:),'dat')
        load(fname);
    end
end



if contains(full_files(file_idx,:),'REC') || contains(full_files(file_idx,:),'edf') || contains(full_files(file_idx,:),'EDF')
    eeg = false;
    clear EEG
elseif contains(full_files(file_idx,:),'dat')
    eeg = true;
end


%% Define parameters


if eeg  % For data in EEG format
    rsearch = prompt('research study');
    if ~exist('EEGr', 'var')
        EEGr = EEG;
        EEGr = make_EEG(EEGr, 'update');
        EEG = make_EEG(EEG, 'update');
    end
    
    if any(cellfun(@(x) strcmp(x,rsearch), strsplit(fname,'_')))
        prompt('duplicate research', EEGr.ref)
    gdat = EEG.data;
    glab = {EEG.chanlocs.labels};
    
    if any(cellfun(@(x) strcmp(x,'RAW'), strsplit(fname,'_')))
        raw_ref_typ = prompt('choose ref type');
        if strcmp(raw_ref_typ, 'mono') || strcmp(raw_ref_typ, 'monopolar')
            if user_yn('artifact rem?')
                gdat_r = EB_removal(EEG.data);
            else
                gdat_r = EEG.data;
            end
            glab_r = {EEG.chanlocs.labels}';
            EEGr = make_EEG(EEG, 'dat', gdat_r, 'labels', glab_r, 'reference', 'monopolar');
        else
            gdat_r = EEGr.data;
            glab_r = {EEGr.chanlocs.labels};
        end
    end
    
    task = strsplit(EEGr.setname, '_');
    task = char(task(end));
    fs = EEGr.srate;
    
    rtm = [EEGr.event.resp]';
    evn = {EEGr.event.type}';  
    evn_idc = [EEGr.event.latency]';
    
    prompt('disp event labels', evn);
    if strcmp(location, 'San_Diego') && user_yn('change code?')
        cv = readtable(sprintf('%s/%s_CV_%s.xlsx', df_dir, subj, task));
        [nevn, rtm] = make_evn_codes(cv);
        an_evn_msk = ismember(evn,{EEGr.analysis.type}');
        new_an_evn = nevn(an_evn_msk);
        if ~isempty(new_an_evn)
            olevn_rej = evn(~an_evn_msk);
            evn_rej = nevn(~an_evn_msk);
        else
            olevn_rej = {};
            evn_rej = {};
        end
        EEGr = make_EEG(EEGr, 'AnalysisEventIdx', [EEGr.analysis.latency]', 'AnalysisEventType', new_an_evn, 'AnalysisResponseTime', [EEGr.analysis.resp]', 'EventIndex', evn_idc, 'EventType', nevn, 'ResponseTime', rtm, 'EventReject', evn_rej);
        EEG = make_EEG(EEG, 'AnalysisEventIdx', [EEGr.analysis.latency]', 'AnalysisEventType', new_an_evn, 'AnalysisResponseTime', [EEGr.analysis.resp]', 'EventIndex', evn_idc, 'EventType', nevn, 'ResponseTime', rtm, 'EventReject', evn_rej);
        olevn = evn;
        evn = nevn;
    elseif strcmp(location, 'Marseille') && user_yn('change code?')
        evn = cellfun(@(x) erase(x, ' '), evn, 'uni', 0);
        trial_num = ones(length(evn),1);
        bound_msk = cellfun(@(x) strcmpi(x,'boundary'), evn);
        trial_num(bound_msk) = 0; 
        trial_num(logical(trial_num)) = 1:length(evn(~bound_msk));
        trial_num(trial_num == 0) = nan;
        RTCV = rtm;
        cv = table(trial_num, evn, RTCV);
        [evn, rtm] = make_evn_codes(cv);
    end
    
    excess_chans = {EEG.reject.excess}';
    edat = [];
    
else  % For data in Hdr/Rec format
    rsearch = 'RAW';
    gdat = Rec;
    glab = Hdr.label;
    EEGr = make_EEG();
    EEG = make_EEG();
    
    fs = prompt('fs');
    task = prompt('task name', 'StroopNamingVerbGen');
    
    cv = readtable(sprintf('%s/%s_CV_%s.xlsx', df_dir, subj, task));
    [evn, rtm] = make_evn_codes(cv);
    
    
    [gdat, evn_idc, ~, xrng, yrng] = event_locater(gdat, glab, Rec, 0);
    
    EEGr = make_EEG(EEGr, 'Name', [subj '_' task], 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm);
    EEG = make_EEG(EEG, 'Name', [subj '_' task], 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm);
    
    excess_chans = {};
    edat = [];
    
    while true
        chans = prompt('remove channels', glab);
        if ~sum(chans == 0)
            [gdat, glab, edat, excess_chans] = remove_channels(gdat, glab, chans, edat, excess_chans);
        else
            break
        end
    end

    [gdat_r, glab_r] = bipolar_referencing(gdat, glab);
    
    EEG = make_EEG(EEG, 'dat', gdat, 'labels', glab, 'ExcessChans', excess_chans, 'ExcessChansData', edat, 'reference', 'monopolar');
    EEGr = make_EEG(EEGr, 'dat', gdat_r, 'labels', glab_r, 'reference', 'bipolar');
end

%% Filter Line Noise

if ~isempty(EEGr.notch)
    numf = length(EEGr.notch);
    flt = prompt('notch filt freq', EEGr.notch);
    flt = [EEGr.notch flt];
else
    numf = 0;
    flt = prompt('notch filt freq');
end

if flt(end) > -1
    p = parpool;
    for f = numf+1:length(flt)
        gdat_r = remove_line_noise_par(gdat_r', flt(f), fs, 1)'; %funciton written by Leon in order to notch filter the data.
        gdat = remove_line_noise_par(gdat', flt(f), fs, 1)';
    end

    delete(p)
    
    if size(gdat_r, 1) > size(gdat_r, 2)
        gdat_r = gdat_r';
    end
    
    if size(gdat, 1) > size(gdat, 2)
        gdat = gdat';
    end
    
    EEGr = make_EEG(EEGr, 'dat', gdat_r, 'NotchFilter', flt, 'saved', 'no');
    EEG = make_EEG(EEG, 'dat', gdat, 'NotchFilter', flt, 'saved', 'no');
end


%% Event Rejection & Channel Rejection

if isfield(EEGr.event, 'reject')
    evn_rej = {EEGr.event.reject}';
    evn_rej = evn_rej(cellfun(@(x) ~isempty(x), evn_rej));
else
    evn_rej = {};
end

if isfield(EEGr.reject, 'rej')
    crej_lab = {EEGr.reject.rej}';
    crej_lab = crej_lab(cellfun(@(x) ~isempty(x), crej_lab));
else
    crej_lab = {};
end

if isfield(EEGr.datreject, 'reject')
    rdat = EEGr.datreject.reject;
else
    rdat = [];
end

ecrej = {};

k = 0;

% channel/event selection & eegplot
while eeg
    
     if isempty(ecrej)
         pop_eegplot(EEGr);
         if strcmp(EEGr.ref, 'bipolar') && k == 0
             pop_eegplot(EEG);
         end
     end
    
    if k == 0
        ecrej = prompt('ecrej header', evn, evn_idc);
    else
        ecrej = prompt('arrow');
    end
   
    ecrej = strsplit(ecrej);

    % Reject Events
    if  str2double(ecrej{1}) == 0
        break      
        
    elseif strcmpi(ecrej{1}, 'event')      
        if strcmpi(ecrej{2}, 'contains')
            rej_idx = find(cellfun(@(x) contains(x, ecrej{3}), evn) == 1);
        elseif strcmpi(ecrej{2}, 'replace')
            rej_idx = [];
            if strcmpi(ecrej{3}, 'old') && strcmpi(ecrej{4}, 'contains')
                evn_rej(cellfun(@(x) contains(x, ecrej{5}), olevn_rej)) = [];
            elseif strcmpi(ecrej{3}, 'contains')
                evn_rej(cellfun(@(x) contains(x, ecrej{4}), evn_rej)) = [];
            else
                for ii = 3:length(ecrej)
                    evn_rej(cellfun(@(x) strcmp(x, ecrej{ii}), evn_rej)) = [];
                end
            end
        else
            rej_idx = [];
            for ii = 2:length(ecrej)
                rej_idx = [rej_idx; find(cellfun(@(x) strcmp(x, ecrej{ii}), evn) == 1)];
            end
        end

        for ii = 1:length(rej_idx)
            if sum(cellfun(@(x) strcmp(x, evn{rej_idx(ii)}), evn_rej)) > 0
                % prompt('skipping event', evn{rej_idx(ii)});
                rej_idx(ii) = -1;
            end
        end
        rej_idx(rej_idx == -1) = [];
        evn_rej = [evn_rej; evn(rej_idx)];


    % Reject Channels
    elseif strcmpi(ecrej{1}, 'channel')
        if strcmpi(ecrej{2}, 'replace')
            for ii = 3:length(ecrej)
                didx = cellfun(@(x) strcmp(x, ecrej{ii}), crej_lab);
                gdat_r = [gdat_r; rdat(didx,:)];
                glab_r = [glab_r, crej_lab(didx)];
                rdat(didx,:) = [];
                crej_lab(didx) = [];
            end
        
        else
            crej_no = [];
            for ii = 2:length(ecrej)
                crej_no = [crej_no find(cellfun(@(x) strcmp(x,ecrej{ii}), glab_r))];
            end
            [gdat_r, glab_r, rdat, crej_lab] = remove_channels(gdat_r, glab_r, crej_no, rdat, crej_lab);
        end
        ecrej = {};
        
    elseif strcmpi(ecrej{1}, 'view')
        if strcmpi(ecrej{2}, 'reject') && ~isempty(crej_lab)
            REJ = make_EEG();
            REJ = make_EEG(REJ, 'dat', EEGr.datreject.reject, 'labels', crej_lab, 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn, 'NotchFilter', flt, 'reference', ref);
            pop_eegplot(REJ);
        elseif strcmpi(ecrej{2}, 'excess') && ~isempty({EEGr.reject.excess})
            elab = {EEGr.reject.excess};
            elab = elab(cellfun(@(x) ~isempty(x), elab));
            EX = make_EEG();
            EX = make_EEG(EX, 'dat', EEGr.datreject.excess, 'labels', elab, 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn, 'NotchFilter', flt, 'reference', ref);
            pop_eegplot(EX);
        end
        
    elseif strcmpi(ecrej{1}, 'show')
        if strcmpi(ecrej{2}, 'events')
            prompt('rejected events', evn_rej)
        elseif strcmpi(ecrej{2}, 'channels')
            prompt('rejected channels', crej_lab)
        end
        
    elseif strcmpi(ecrej{1}, 'help')
        prompt('ecrej help')
    end

    EEGr = make_EEG(EEGr, 'dat', gdat_r, 'labels', glab_r, 'RejectChans', crej_lab, 'RejectChansData', rdat, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm, 'EventReject', evn_rej, 'saved', 'no');
    k = k+1;
end


%% Save Data

evn_msk = ~ismember(evn,evn_rej);
an_evn_idc = evn_idc(evn_msk);
an_evn = evn(evn_msk);
an_rtm = rtm(evn_msk);

EEGr = make_EEG(EEGr, 'AnalysisEventIdx', an_evn_idc, 'AnalysisEventType', an_evn, 'AnalysisResponseTime', an_rtm, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm, 'EventReject', evn_rej);
EEG = make_EEG(EEG, 'AnalysisEventIdx', an_evn_idc, 'AnalysisEventType', an_evn, 'AnalysisResponseTime', an_rtm, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm, 'EventReject', evn_rej);

% This IF block seems redundant but I want it to automatically save a raw
% draft if the work was built up from the REC file. This could probably be
% made more efficient.
if ~eeg
    
    EEGr = make_EEG(EEGr, 'saved', 'yes');
    EEG = make_EEG(EEG, 'saved', 'yes');
    sname = sprintf('%s/%s_%s_%s_dat.mat', df_dir, subj, task, rsearch);
    
    disp('  ')
    disp('Saving...')
    
    if strcmp(EEGr.ref, 'bipolar')
        save(sname, 'EEGr', 'EEG','-v7.3')
    else
        save(sname, 'EEGr','-v7.3')
    end
    
elseif user_yn('save EEG?')
    
    EEGr = make_EEG(EEGr, 'saved', 'yes');
    EEG = make_EEG(EEG, 'saved', 'yes');
    sname = sprintf('%s/%s_%s_%s_%s_dat.mat', df_dir, subj, task, rsearch, EEGr.ref);
    
    disp('  ')
    disp('Saving...')
    
    if strcmp(EEGr.ref, 'bipolar')
        save(sname, 'EEGr', 'EEG','-v7.3')
    else
        save(sname, 'EEGr','-v7.3')
    end
    
end
% close all

if user_yn('process another?')
    run('iEEGprocessor.m')
else
    disp('  ')
    disp('Good-bye!')
    disp('  ')
end



















