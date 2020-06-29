%%%
%   iEEG processor
%   Connor Sperling, 09/15/19
%   Revised: 06/26/20
%     
%   A user friendly command line interface program for loading, 
%   pre-processing and performing artifact rejection on iEEG data
%
%   INPUT
%   This program reads data in mutiple different formats:
%       - .EDF: Original file from UCSD medical center
%       - REC/HDR.mat: Format of the output of edfread() which unpacks the
%                      original EDF file
%       - dat.mat: Format of the ouput of this program
%        
%   OUTPUT     
%       - EEG struct automatically saved to subject data directory in 
%         dat.mat format
%       
%         - Contains data, channel labels, stimulus event information,
%           artifact rejection information, and more
%%%


%% Define subject & set paths

warning('off')
close all
clear
clc

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

cd(subjs_dir)

% Grab all current subject directories
d = dir;
pts = {d.name};
pts = pts(cellfun(@(x) contains(x,'sd') || contains(x,'pt'), pts));

% user inputs subject ID. only accepts subject ID if in pts array
subj = prompt('define subject', subjs_dir, pts, location);

pth = sprintf('%s/%s', subjs_dir, subj); % Path to subject directory

% assigns data directory
df_dir = sprintf('%s/data', pth); % Path to subject's data directory

% Note: All subjects should have a data and analysis sub-directories
   

%% Choose and load data

cd(df_dir);

rec_files = dir('*REC.mat'); % List of REC files
hdr_files = dir('*HDR.mat'); % List of HDR files
eeg_files = dir('*dat.mat'); % List of dat files
edf_files = dir('*.EDF'); % List of EDF files
full_files = [{rec_files.name} {eeg_files.name} {edf_files.name}];


% For CLI display
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
    % full_files displayed in a numbered list. User enters the number of
    % the data they want to load
    file_idx = prompt('choose file', full_files);
end

% Loads data based on file type
fname = strtrim(full_files(file_idx,:));
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



% Two different paths exist in this program depending on whether data has
% been previously processed or not
if ~exist('EEG', 'var') %contains(full_files(file_idx,:),'REC') || contains(full_files(file_idx,:),'edf') || contains(full_files(file_idx,:),'EDF')
    eeg = false;
    clear EEG
else %if contains(full_files(file_idx,:),'dat')
    eeg = true;
end


%% Define parameters


if eeg  % For data in EEG format
    rsearch = prompt('research study'); % name research study (original data set may be processed in numerous ways)
    % Marseille data is initially imported in EEG format less some
    % additional fields in the struct. This updates it if this is it's
    % first processing session.
    if strcmp(location, 'Marseille') && any(cellfun(@(x) strcmp(x,'RAW'), strsplit(fname,'_')))
        EEG = make_EEG(EEG, 'update');
    end
    
    gdat = EEG.data; % iEEG data matrix (channel x time)
    glab = {EEG.chanlocs.labels}; % names of all iEEG contacts/channels
    
    task = strsplit(EEG.setname, '_'); % Naming, Stroop, VerbGen, etc.
    task = char(task(end));
    fs = EEG.srate; % sampling rate
    
    
    rtm = [EEG.event.resp]'; % reaction time associated with each event
    evn = {EEG.event.type}'; % event names
    evn_idc = [EEG.event.latency]'; % event indicies
    
    % Option to change event names
    prompt('disp event labels', evn);
    if user_yn('change code?')
        cv = readtable(sprintf('%s/%s_CV_%s.xlsx', df_dir, subj, task)); % reads behavioral data associated with patient/task
        % Temporary patch for Marseille data
%         bound_msk = cellfun(@(x) strcmpi(x,'boundary'), evn); % marks events called 'boundary' from Marseille data
%         ipt = input('cellfun(@(x) contains(x,255), evn) (0) or false(size(bound_msk)) (1): ');
%         if ipt
%             s255_msk = false(size(bound_msk)); 
%         else
%             s255_msk = cellfun(@(x) contains(x,'255'), evn);
%         end
%         msk = or(bound_msk, s255_msk);
        msk = false(size(evn)); % temporary
        [nevn, rtm, evn_code] = make_evn_codes(cv, msk); % names each event with the chosen behavioral data parameters
        
        % Translates the event rejection from a previous event naming
        % scheme to the new names. Allows user to replace previously
        % rejected event based on the new event name
        an_evn_msk = ismember(evn,{EEG.analysis.type}');
        new_an_evn = nevn(an_evn_msk);
        if ~isempty(new_an_evn)
            olevn_rej = evn(~an_evn_msk);
            evn_rej = nevn(~an_evn_msk);
        else
            olevn_rej = {};
            evn_rej = {};
        end
        
        % Updates EEG stucture with new event names
        EEG = make_EEG(EEG, 'EventCode', evn_code, 'AnalysisEventIdx', [EEG.analysis.latency]', 'AnalysisEventType', new_an_evn, 'AnalysisResponseTime', [EEG.analysis.resp]', 'EventIndex', evn_idc, 'EventType', nevn, 'ResponseTime', rtm, 'EventReject', evn_rej);
        olevn = evn;
        evn = nevn;
    end
    
    % Outdated. Not really necessary currently
    excess_chans = {EEG.reject.excess}';
    edat = [];
    
else  % For data in Hdr/Rec format
    % The goal of loading in data in Hdr/Rec format only to make a RAW_dat
    % file which will be used for all future studies/processing of that data set
    rsearch = 'RAW';
    gdat = Rec; % data matrix (channel x time)
    glab = Hdr.label; % names of all iEEG contacts/channels
    EEG = make_EEG(); % EEG struct skeleton
    
    fs = prompt('fs'); % User inputs sampling rate
    task = prompt('task name', 'StroopNamingVerbGen'); % User chooses task name
    
    cv = readtable(sprintf('%s/%s_CV_%s.xlsx', df_dir, subj, task)); % read behavioral data
    
    % Makes the event names based off user input of which behavioral data 
    % to use. Since this is a raw file, keep name non-specific. 
    % Also retrives subject response time (rtm) for each event
    [evn, rtm, evn_code] = make_evn_codes(cv); 
    
    % plots trigger channel from iEEG data which signifies the time of each
    % event. Occasionally more than one task reseides in the data matrix
    % which adds unnessary computation time in analysis steps.
    % User is able to select the time window in which the desired data
    % resides in. Only this data is saved.
    [gdat, evn_idc, ~, xrng, yrng] = event_locater(gdat, glab, Rec, 0); 
    
    % Update EEG struct with all user selected information
    EEG = make_EEG(EEG, 'Name', [subj '_' task], 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm);
    
    % There are usually many unnecessary, non-iEEG channels in the data
    % matrix. This allows user to select which channels are superfluous
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

    % Possible addition which will automatically remove artifacts from all
    % data
%     gdat = EB_removal(gdat);
    
    % Update struct with cleaned data
    EEG = make_EEG(EEG, 'dat', gdat, 'labels', glab, 'ExcessChans', excess_chans, 'ExcessChansData', edat, 'reference', 'monopolar');

end

%% Filter Line Noise
% Allows user to select any frequency they would like to notch. This is
% really only necessary for 60 Hz line noise and its harmonics which is
% handled by remove_line_noise_par(). This will be automated in future
% versions
if ~eeg
    if ~isempty(EEG.notch)
        numf = length(EEG.notch);
        flt = prompt('notch filt freq', EEG.notch);
        flt = [EEG.notch flt];
    else
        numf = 0;
        flt = prompt('notch filt freq');
    end

    if flt(end) > -1
        p = parpool;
        for f = numf+1:length(flt)
            gdat = remove_line_noise_par(gdat', flt(f), fs, 1)';
        end

        delete(p)

        if size(gdat, 1) > size(gdat, 2)
            gdat = gdat';
        end

        EEG = make_EEG(EEG, 'dat', gdat, 'NotchFilter', flt, 'saved', 'no');
    end
end


%% Event Rejection & Channel Rejection

% In this section, user is able to reject events for future analysis,
% reject noisy channels, or replace previously rejected events/channels

% Gets list of previously rejected events, if any
if isfield(EEG.event, 'reject')
    evn_rej = {EEG.event.reject}';
    evn_rej = evn_rej(cellfun(@(x) ~isempty(x), evn_rej));
else
    evn_rej = {};
end

% Gets list of previously rejected channels, if any
if isfield(EEG.reject, 'rej')
    crej_lab = {EEG.reject.rej}';
    crej_lab = crej_lab(cellfun(@(x) ~isempty(x), crej_lab));
else
    crej_lab = {};
end

% Gets previously rejected data, if any
if isfield(EEG.datreject, 'reject')
    rdat = EEG.datreject.reject;
else
    rdat = [];
end

% variable event/channel rejection cell array which recieves user input
ecrej = {};

f = true;

% channel/event selection & eegplot
while eeg
    
    % invokes subfunction of EEGLAB to plot data and event markers in one pop-up window
    if isempty(ecrej)
        pop_eegplot(EEG); 
    end
    
    % Displays event list and help menu on first loop, takes user input
    if f
        ecrej = prompt('ecrej header', evn, evn_idc); 
    else
        ecrej = prompt('arrow');
    end
    
    ecrej = strsplit(ecrej); 

    % user entering 0 stops AR section
    if  str2double(ecrej{1}) == 0 
        break      
    
    % Reject/Replace Events
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


    % Reject/Replace/View Channels
    elseif strcmpi(ecrej{1}, 'channel')
        if strcmpi(ecrej{2}, 'replace')
            for ii = 3:length(ecrej)
                didx = cellfun(@(x) strcmp(x, ecrej{ii}), crej_lab);
                gdat = [gdat; rdat(didx,:)];
                glab = [glab, crej_lab(didx)];
                rdat(didx,:) = [];
                crej_lab(didx) = [];
            end
        
        else
            crej_no = [];
            for ii = 2:length(ecrej)
                crej_no = [crej_no find(cellfun(@(x) strcmp(x,ecrej{ii}), glab))];
            end
            [gdat, glab, rdat, crej_lab] = remove_channels(gdat, glab, crej_no, rdat, crej_lab);
        end
        ecrej = {};
        
    elseif strcmpi(ecrej{1}, 'view')
        if strcmpi(ecrej{2}, 'reject') && ~isempty(crej_lab)
            REJ = make_EEG();
            REJ = make_EEG(REJ, 'dat', EEG.datreject.reject, 'labels', crej_lab, 'srate', fs, 'EventIndex', evn_idc, 'EventType', evn);
            pop_eegplot(REJ);
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

    EEG = make_EEG(EEG, 'dat', gdat, 'labels', glab, 'RejectChans', crej_lab, 'RejectChansData', rdat, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm, 'EventReject', evn_rej, 'saved', 'no');
    f = false;
end

evn_msk = ~ismember(evn,evn_rej);
an_evn_idc = evn_idc(evn_msk);
an_evn = evn(evn_msk);
an_rtm = rtm(evn_msk);

EEG = make_EEG(EEG, 'AnalysisEventIdx', an_evn_idc, 'AnalysisEventType', an_evn, 'AnalysisResponseTime', an_rtm, 'EventIndex', evn_idc, 'EventType', evn, 'ResponseTime', rtm, 'EventReject', evn_rej);


%% Save Data

EEG = make_EEG(EEG, 'saved', 'yes');
sname = sprintf('%s/%s_%s_%s_monopolar_dat.mat', df_dir, subj, task, rsearch);

disp('  ')
disp('Saving...')

save(sname, 'EEG','-v7.3')

% Bipolar references data i.e. LA1 LA2 LA3 ... --> LA02-01 LA03-02 ...
if user_yn('bipolar reference?')
    EEGmon = EEG;
    [gdat_r, glab_r] = bipolar_referencing(gdat, glab);
    EEG = make_EEG(EEG, 'dat', gdat_r, 'labels', glab_r, 'reference', 'bipolar');
    pop_eegplot(EEG)
    sname = sprintf('%s/%s_%s_%s_bipolar_dat.mat', df_dir, subj, task, rsearch);
    save(sname, 'EEG','-v7.3')
end
    
% Restart prog for another data set
if user_yn('process another?')
    run('iEEGprocessor_new.m')
else
    disp('  ')
    disp('Good-bye!')
    disp('  ')
end



















