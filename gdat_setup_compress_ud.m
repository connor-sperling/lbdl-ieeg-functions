%%

%   organizes variables and raw data for all subjects, tasks, blocks
%   downsamples files with srate over 1KHz (GP and ST only)
%   run after you exported files into matlab from TDT or EDF
%   user-friendly version, created on 02/21/09 by AS, modified on 08/18/09
%
%   VARIABLE GUIDE:
%
%       PATH VARIABLES:
%           pth - path to the subject directory (Subjs/SUBID/)
%           data_dir - path to the Subjs/SUBID/Data Files directory
%           TANK - shortcut for the path into Subjs/SUBID/Data Files/"block name" dir;
%                  to be used with data_dir 
%           TDdir - path to the Subjs/SUBID/data directory
%   
%  
%       SUBJECT/TASK VARIABLES:
%
%           SUBID - subject ID
%           meta_ID - block ID used during recordings (either for edf or
%                     tdt files)
%           Study - study code name
%           Blocks - total number of blocks per study
%           Study_num - number of a current study being analyzed
%           Block_num - number of a current block being analyzed
%
%
%       EEG/ANALOG CHANNEL VARIABLES
%
%           mic_num - analog channel number for the mic
%           spkr_num - analog channel number for the speaker (first only)
%           photo_num - analog channel number for the photodiode
%           srate - sampling rate for electrode channels
%           ANsrate - sampling rate for analog channels
%            
%       ELECTRODE MATRIX CONFIGURATION VARIABLES           
%
%           original_indx_map - electrode configuration used in the
%                               original edf or tdt file
%           grid_indx_map - new configuration that will be used for current
%                           analyses
%           grid_good_map_new - new configuration without bad electrodes
%           grid_indx_map_new - grid_indx_map configuration arranged to
%                               match the grid_good_map_new configuration for conversion
%           bad_elecs - bad electrodes
%           bad - test variable for bad electrodes to decrease input
%           bad_elec_test - see 'bad'
%           elecs - list of good electrodes for subject global variables
%           total_elecs - number of electrodes in the final electrode matrix
%
%       OUTPUT FILES           
%           
%           gdat - new all-electrodes matrix file with all electrodes
%           gdat_clean - new matrix file with good electrodes only
%           gdat_specs - list of all inputs from this file for future
%                        references
%           subj_globals - list of essential subject variables, stored in
%                          the analysis directory
%
%       OUTSIDE SCRIPTS USED
%
%           create_subj_globals - script written by Adeen in ECG_script dir
%           eegplot - eeglab script for viewing data
%

warning('off')
close all
subjs_dir = 'L:/iEEG_San_Diego/Subjs/';
%subjs_pth = '/Users/connor-home/Desktop/LBDL/';
cd(subjs_dir)

d = dir;
pts = {d.name};
pts = pts(cellfun(@(x) contains(x,'SD'), pts));

while true  
    SUBID = input('\nSubject ID: ', 's');
    if any(cellfun(@(x) contains(x,SUBID), pts))
        break
    else
        msg = sprintf('\n%s does not have a folder in the directory: %s\nWould you like to make folders for %s? (y/n)\n--> ', SUBID, subjs_dir, SUBID);
        yn = input(msg, 's');
        if strcmp(yn, 'y') || strcmp(yn, 'yes')
            mkdir([subjs_dir SUBID '/analysis/'])
            mkdir([subjs_dir SUBID '/data/'])
            mkdir([subjs_dir SUBID '/Data Files/'])
            break
        end
    end
end

subj_num = str2double(SUBID(regexp(SUBID,'\d')));

pth = [subjs_dir SUBID '/'];

% assigns data directory
df_dir = [pth 'Data Files/'];                  
   
cd(df_dir);

%% Load Rec/Hdr files & Patient Info table
while true
    rec_files = dir('*REC.mat');
    hdr_files = dir('*HDR.mat');
    eeg_files = dir('*dat.mat');
    full_files = [{rec_files.name} {eeg_files.name}];
    rec_files = char({rec_files.name});
    hdr_files = char({hdr_files.name});
    eeg_files = char({eeg_files.name});
    full_files = char(full_files);
    
    % Files found in df_dir are written to lists (rec_files, etc.). If it
    % didnt find any files, warning is thrown and user has option to place
    % files in df_dir
    if (isempty(rec_files) || size(hdr_files,1) ~= size(rec_files,1)) && isempty(eeg_files)
        disp('Looks like there is insufficient data in this patients data files directory')
        disp('Here is what is in your current directoy:')
        dir
        msg = sprintf('You may add data to %s now.\nMake sure to also create Excel files in this directory with the names %s_info.xlsx and %s_info_bipolar.xlsx \nPress ENTER to continue...', df_dir, SUBID, SUBID);
        input(msg, 's');
        continue
    else
        disp('  ')
        disp('Data files found:')
        for ii = 1:size(full_files,1)
            msg = sprintf('\t%d. %s ', ii, full_files(ii,:));
            disp(msg)
        end
        file_idx = input('\nChoose the number of the .mat you would like to proceed with: ');
    end
    
    while true
        % Option to load in file. Saves user time if file already exists in ws
        yn = input('\nWould you like to load in this file? (y/n)\n--> ', 's');

        if strcmp(yn, 'y') || strcmp(yn, 'yes')
            disp('Working.... ');
            if contains(full_files(file_idx,:),'REC')
                load([strtrim(erase(full_files(file_idx,:),'REC.mat')) 'HDR.mat']);
                load(full_files(file_idx,:));
                break
            elseif contains(full_files(file_idx,:),'dat')
                load(full_files(file_idx,:));
                break
            end
        elseif strcmp(yn, 'n') || strcmp(yn, 'no')
            break
        end
    end
    
    if exist('Rec') || exist('EEG')
        break
    end
end


if exist('Rec') && exist('EEG')
    while true
        pick = input('\nDo you want to use the data set Rec or EEG?\n--> ', 's');
        if strcmpi(pick, 'rec')
            eeg = false;
            break
        elseif strcmpi(pick, 'eeg')
            eeg = true;
            break
        end
    end
elseif exist('Rec')
    eeg = false;
elseif exist('EEG')
    eeg = true;
end


%% Prep Data

%%% IF DATA LOADED IN IS IN EEG FORMAT/HAS ALREADY BEEN PROCESSED %%%
if eeg
    gdat = EEG.data;
    glab = {EEG.chanlocs.labels};
    % Confirms with user whether or not the data has already been
    % re-referenced. Necessary to load in the correct XL file.
    disp('  ')
    disp('Here are some of the channels from this data:')
    glab_abbv_disp = char([glab {'   .', '   .', '   .'}]);
    disp(glab_abbv_disp([1:5, size(glab_abbv_disp,1)-2:size(glab_abbv_disp,1)],:))
    yn = input('Is this re-referenced data? (y/n)\n--> ', 's');
    
    if strcmp(yn, 'yes') || strcmp(yn, 'y')
        xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
        bp = 'no'; % If data has already been re-referenced, no need to re-reference again. Set bp to 'no' to avoid that block later on
    else
        % When the processed data has not been re-referenced, this gives
        % the user the option to do so. Loads in the appropriate XL file
        bp = input('Would you like to re-reference it? (y/n)\n--> ', 's');
        if strcmp(bp, 'yes') || strcmp(bp, 'y')
            xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
        else
            xl_name = sprintf('%s_info.xlsx', SUBID);
        end
    end
    
    task = strsplit(EEG.setname, '_');
    task = char(task(end));
   
    % Reads in the appropriate info from pt-info XL file
    patinf = readtable(xl_name, 'Sheet', task);
   
    % Wrap these to string to make matlab happy when appending to these
    patinf.Good_Channels = string(patinf.Good_Channels);
    patinf.Excess_Channels = string(patinf.Excess_Channels);
    patinf.Channel_Reject = string(patinf.Channel_Reject);
    patinf.Event_Reject = string(patinf.Event_Reject);
    patinf.Event_Types = string(patinf.Event_Types);
    
    evns = patinf.Stimulus_Event(~isnan(patinf.Stimulus_Event));

%%% IF DATA LOADED IN IS IN REC FORMAT AND NEEDS TO BE PROCESSED %%%
else
    gdat = Rec;
    glab = Hdr.label;
    
    while true
        disp('  ')
        bp = input('Do you want to re-reference this data? (y/n)\n--> ', 's');
        if strcmp(bp, 'yes') || strcmp(bp, 'y')
            xl_name = sprintf('%s_info_bipolar.xlsx', SUBID);
            break
        elseif strcmp(bp, 'no') || strcmp(bp, 'n')
            xl_name = sprintf('%s_info.xlsx', SUBID);
            break
        else
            continue
        end
    end
    
    trig_idx = find(cellfun(@(x)isequal(x,'TRIG'),glab));
    trigchan = gdat(trig_idx,:);
    
    n = 1;
    while true
        figure(n)
        plot(trigchan)
        
        trim_rng = input('\nEnter x-axis range of data you wish to delete (0 for None)\n--> ', 's');
        if strcmpi(trim_rng, 'reset')
            gdat = Rec;
            trigchan = gdat(trig_idx,:);
            n = n + 1;
            continue
        elseif strcmp(trim_rng(1), '[') || str2double(trim_rng) == 0
            trim_rng = erase(trim_rng, ["[", "]"]);
            trim_rng = str2double(strsplit(trim_rng, ','));
        else
            continue
        end  
        
        if sum(trim_rng == 0)
            break
        else
            gdat = gdat(:,trim_rng(1):trim_rng(2));
            trigchan = trigchan(trim_rng(1):trim_rng(2));
            if n == 1
                trim_save = trim_rng;
            end
        end
        n = n + 1;
    end

    evns_value_rng = input('\nEnter y-axis range that capture event spikes in plot\n--> ');

    possible_tasks = 'StroopNamingVerbGen';
    while true
        task = input('\nEnter the Study Code: ', 's');
        if contains(possible_tasks, task)
            break
        end
    end
    patinf = readtable(xl_name, 'Sheet', task);

    patinf(cellfun(@(x) isempty(x), patinf.Event_Types),:) = [];
    patinf.Data_Start = nan(size(patinf,1),1);
    patinf.Data_Stop = nan(size(patinf,1),1);
    patinf.Good_Channels = string(nan(size(patinf,1),1));
    patinf.Excess_Channels = string(nan(size(patinf,1),1));
    patinf.Channel_Reject = string(nan(size(patinf,1),1));
    patinf.Event_Reject = string(patinf.Event_Reject);
    patinf.Event_Types = string(patinf.Event_Types);


    patinf.Data_Start(1) = trim_save(1);
    patinf.Data_Stop(1) = trim_save(2);

    evns = find(trigchan > evns_value_rng(1) & trigchan < evns_value_rng(2));
    de = diff(evns);
    unique_msk = [true de ~= 1];
    unique_msk(end) = [];
    evns = evns(unique_msk);
    evns = evns';
    patinf.Stimulus_Event = [];
    patinf.Stimulus_Event(1:length(evns)) = evns;
end

evn_typ = cellstr(patinf.Event_Types(~ismissing(patinf.Event_Types)));

srate = input('\nEnter the sampling rate: ');




%% Bipolar Reference & Remove excess channels manually

if strcmp(bp, 'yes') || strcmp(bp, 'y')
    disp('Working...') 
    [gdat_r, glab_r] = bipolar_referencing(gdat, glab);
    
    removed = '';
    while true
        disp('  ')
        disp('------------------------------------')
        disp([num2str(transpose(1:length(glab_r))) char(ones(length(glab_r),1) * '.  ') char(glab_r)])
        chans = input('\nEnter numbers of any channels you wish to remove (Enter 0 for None)\n--> ');
        if ~sum(chans == 0)
            [gdat_r, glab_r, removed] = remove_channels(gdat_r, glab_r, chans, removed);
        else
            break
        end
    end

    removed = strsplit(removed, ',');
    nadd = size(patinf,1) - length(removed);
    if nadd > 0
        for ii = 1:nadd
            removed = [removed string(nan)];
        end
        patinf.Excess_Channels = removed';
    elseif nadd < 0
        for ii = 1:length(removed)
            if ii > size(patinf,1)
                patinf.Data_Start(ii) = nan;
                patinf.Data_Stop(ii) = nan;
                patinf.Good_Channels(ii) = string(nan);
                patinf.Channel_Reject(ii) = string(nan);
                patinf.Event_Reject_No(ii) = nan;
                patinf.Event_Reject(ii) = string(nan);
                patinf.Event_Types(ii) = string(nan);
                patinf.Response_Time(ii) = nan;
                patinf.Stimulus_Event(ii) = nan;
            end
           patinf.Excess_Channels(ii) = removed{ii};
        end
    else
        patinf.Excess_Channels = removed';
    end

else
    gdat_r = gdat;
    glab_r = glab;
end


    

%% Event Rejection & Channel Rejection
bad_elecs = [];
chan_rej = '';
alph_chk = {};
k = 0;
if sum(~ismissing(patinf.Event_Reject)) == 0
    patinf.Event_Reject = num2cell(patinf.Event_Reject);
    rej_all_no = [];
    rej_all = {};
    no_evn_rej = 0;
else
    no_evn_rej = find(isnan(patinf.Event_Reject_No),1)-1;
    rej_all_no = patinf.Event_Reject_No(1:no_evn_rej);
    rej_all = patinf.Event_Reject(1:no_evn_rej);
end



if exist('EEG', 'var')
    freqs = 0;
else
    EEG = struct;
    EEG.filter = [];
    freqs = EEG.filter;
end
EEG = make_EEG(gdat_r, glab_r, srate, evns, evn_typ, freqs, [SUBID '_' task]);

    
while true
    disp('  ')
    disp('    Events      Event idx')
    disp([char(ones(length(evn_typ),1) * '     ')  char(evn_typ) char(ones(length(evn_typ),1) * '     ') num2str(evns)])
    
    no_evn_rej = length(rej_all_no);
    if ~isempty(rej_all_no)
        disp('  ')
        disp('The following events have already been marked to reject:')
        disp('  ')
        disp(' Event no.   Event name')
        disp([char(ones(no_evn_rej,1) * '     ') num2str(rej_all_no) char(ones(no_evn_rej,1) * '           ') char(rej_all)])
        disp('  ')
    end
    if ~isempty(chan_rej)
        disp('  ')
        disp('The following channels have been rejected:')
        disp('  ')
        chan_rej_disp = char(strsplit(chan_rej, ','));
        disp([char(ones(size(chan_rej_disp,1),1) * '     ') chan_rej_disp])
        disp('  ')
    end
    

    
    if k == 0 || ~all(cellfun(@(x) isempty(x), alph_chk))
        pop_eegplot(EEG);
    end
    
    
    ecrej = input('\nEnter the numbers of events you wish to reject or the names of the channels you want to reject (Enter 0 to stop)\nYou can clear the rejection of EVENTS by entering Replace followed by the event index.\n--> ', 's');
    ecrej = strsplit(ecrej);
    alph_chk = cellfun(@(x) x(isstrprop(x,'alpha')),ecrej,'uni',0);
    
    % Reject Events
    if strcmpi(ecrej{1}, 'event') %all(cellfun(@(x) isempty(x), alph_chk))
        if strcmpi(ecrej{2}, 'contains')
            rej_idx = find(cellfun(@(x) contains(x, ecrej{3}), evn_typ) == 1);
        else       
            rej_idx = cellfun(@(x) str2double(x), ecrej(2:end))';
            if sum(rej_idx == 0) > 0
                break
            end
        end
        
        for ii = 1:length(rej_idx)
            if sum(rej_all_no == rej_idx(ii))
                msg = sprintf('Event %d (%s) has already been selected for rejection. Skipping...', rej_idx(ii), evn_typ{rej_idx(ii)});
                disp(msg)
                rej_idx(ii) = -1;
            end
        end
        rej_idx(rej_idx == -1) = [];
        evn_rej = evn_typ(rej_idx);

        rej_all_no = [rej_all_no; rej_idx];
        rej_all = [rej_all; evn_rej];
        
       

    elseif strcmpi(ecrej{1}, 'event') && all(cellfun(@(x) isempty(x), alph_chk(2:end)))
            rep_idxs = cellfun(@(x) rej_all_no' == str2double(x), ecrej(2:end), 'un', 0);
            rep_idx = zeros(1, length(rep_idxs{1}));
            for ii = 1:length(rep_idxs)
                rep_idx = or(rep_idx, rep_idxs{ii});
            end
            rej_all_no(rep_idx) = [];
            rej_all(rep_idx) = [];
        
    % Reject Channels
    elseif strcmpi(ecrej{1}, 'channel')
        cnum_rej = [];
        for ii = 2:length(ecrej)
            cnum_rej = [cnum_rej find(cellfun(@(x) strcmp(x,ecrej{ii}), glab_r))];
        end
        [gdat_r, glab_r, chan_rej] = remove_channels(gdat_r, glab_r, cnum_rej, chan_rej);
    else
        disp('  ')
        disp('Try again');
        continue
    end
    k = k + 1;
    EEG = make_EEG(gdat_r, glab_r, srate, evns, evn_typ, freqs, [SUBID '_' task]);
end

%% Save all edits to Patient table info
nadd = size(patinf,1) - length(rej_all);
if nadd > 0
    for ii = 1:nadd
        rej_all_no = [rej_all_no; nan];
        rej_all = [rej_all; string(nan)];
    end
    patinf.Event_Reject_No = rej_all_no;
    patinf.Event_Reject = rej_all;
elseif nadd < 0
    for ii = 1:length(rej_all)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Good_Channels(ii) = string(nan);
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Channel_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Event_Reject_No(ii) = rej_all_no{ii};
        patinf.Event_Reject(ii) = rej_all{ii};
    end
else
    patinf.Event_Reject_No = rej_all_no;
    patinf.Event_Reject = rej_all;
end

chan_rej = strsplit(chan_rej, ',');
nadd = size(patinf,1) - length(chan_rej);
if nadd > 0
    for ii = 1:nadd
        chan_rej = [chan_rej string(nan)];
    end
    patinf.Channel_Reject = chan_rej';
elseif nadd < 0
    for ii = 1:length(chan_rej)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Good_Channels(ii) = string(nan);
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Event_Reject_No(ii) = nan;
            patinf.Event_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Channel_Reject(ii) = chan_rej{ii};
    end
else
    patinf.Channel_Reject = chan_rej';
end
       

patinf.Good_Channels = string(patinf.Good_Channels);
glab_r_table = glab_r;
nadd = size(patinf,1) - length(glab_r_table);
if nadd > 0
    for ii = 1:nadd
        glab_r_table = [glab_r_table string(nan)];
    end
    patinf.Good_Channels = glab_r_table';
elseif nadd < 0
    for ii = 1:length(glab_r_table)
        if ii > size(patinf,1)
            patinf.Data_Start(ii) = nan;
            patinf.Data_Stop(ii) = nan;
            patinf.Excess_Channels(ii) = string(nan);
            patinf.Channel_Reject(ii) = string(nan);
            patinf.Event_Reject_No(ii) = nan;
            patinf.Event_Reject(ii) = string(nan);
            patinf.Event_Types(ii) = string(nan);
            patinf.Response_Time(ii) = nan;
            patinf.Stimulus_Event(ii) = nan;
        end
        patinf.Good_Channels(ii) = glab_r_table{ii};
    end
else
    patinf.Good_Channels = glab_r_table';
end

%% FILTER OUT 60 Hz LINE NOISE (If needed)
if ~isempty(EEG.filter)
    msg = sprintf('\nData has been notch filtered at %d Hz.\nWould you like to filter again? Enter frequency in Hz: (-1 for None)\n--> ', EEG.filter(length(EEG.filter)));
    freqs = input(msg);
    freqs = [EEG.filter freqs];
else
    freqs = input('\nApply notch filter? Enter frequency in Hz: (-1 for None)\n--> ');
end

if freqs(end) > -1
    disp('  ')
    disp('Filtering')
    tic
    gdat_r = remove_line_noise_par(gdat_r', freqs(length(freqs)), srate, 1)'; %funciton written by Leon in order to notch filter the data.
    done = toc;
    
    disp('  ')
    disp(['Done filtering in ' num2str(done/60) ' minutes'])
end


if size(gdat_r, 1) > size(gdat_r, 2)
    gdat_r = gdat_r';
end
EEG = make_EEG(gdat_r, glab_r, srate, evns, evn_typ, freqs, [SUBID '_' task]);

%% Save pre-processed data, Save Excel file
xlswrite([df_dir xl_name],nan(100,100), task)
writetable(patinf, [df_dir xl_name], 'Sheet', task)

s = input('\nDo you want to save your work? (y/n)\n--> ', 's');
if strcmp(s, 'yes') || strcmp(s, 'y')
    save([df_dir SUBID '_' task '_dat.mat'], 'EEG')
end


%% Create directories for HGA
if contains(xl_name, 'bipolar')
    ref = 'bipolar';
else
    ref = 'mono';
end

stim_pth = [pth 'analysis/' task '/' ref '/Stimulus Locked/'];
resp_pth = [pth 'analysis/' task '/' ref '/Response Locked/'];

stim_ALL_pth = [stim_pth 'ALL/'];
resp_ALL_pth = [resp_pth 'ALL/'];

if ~exist([stim_ALL_pth 'Channel events/'], 'dir')
    mkdir([stim_ALL_pth 'Channel events/']);
    mkdir([stim_ALL_pth 'plots - events/']);
    mkdir([stim_ALL_pth 'plots - HGA/']);
    mkdir([stim_ALL_pth 'TvD/']);
    mkdir([stim_ALL_pth 'HGA figs/']);
end


if ~exist([resp_ALL_pth 'Channel events/'], 'dir')
    mkdir([resp_ALL_pth 'Channel events/']);
    mkdir([resp_ALL_pth 'Event plots/']);
    mkdir([resp_ALL_pth 'HGA plots/']);
    mkdir([resp_ALL_pth 'TvD/']);
    mkdir([resp_ALL_pth 'HGA figs/']);
end


analysis_evns = evns;
analysis_evns(~isnan(rej_all_no)) = [];

%% High Gamma Analysis across ALL events
close all
foc_nm = 'ALL';
while true
    lock_typ = input('\nEnter S for Stimulus Locked Analysis or R for Response Locked analysis (Q to quit)\n--> ', 's');
    if strcmpi(lock_typ, 'q')
        break
    elseif ~(strcmpi(lock_typ, 's') || strcmpi(lock_typ, 'r'))
        continue
    else
        if strcmpi(lock_typ, 's')               
            lock_pth = [stim_pth foc_nm '/'];
        elseif strcmpi(lock_typ, 'r')
            lock_pth = [resp_pth foc_nm '/'];
        end
        
        ce = input('\nDo you want to run sd_channel_events.m? (y/n)\n--> ', 's');
        if strcmp(ce, 'yes') || strcmp(ce, 'y')              
            sd_channel_events_ud(EEG, analysis_evns, lower(lock_typ), lock_pth, ref, foc_nm) 
        end

        hg = input('\nDo you want to run do high gamma analysis? (y/n)\n--> ', 's');
        if strcmp(hg, 'yes') || strcmp(hg, 'y')          
            sd_significant_hfb_ud(EEG, lower(lock_typ), lock_pth, task, ref, foc_nm);
        end
    end
end


% Need to append an IF statement of this type for every new task
if strcmp(task, 'Naming')
    typ_idx = 2;
    focus_typ = 'poscat';
end

%This block is redundant but better than what I had that makes
%analysis_evns/evn_typ
rej_evn_typ = rej_all(~ismissing(rej_all));
all_evn_typ = string(evn_typ);
good_evn_typ = cellstr(all_evn_typ(~ismember(all_evn_typ, rej_evn_typ)));
good_evns = evns(~ismember(all_evn_typ, rej_evn_typ));
goodsplit = cellfun(@(x) strsplit(x, '-'), good_evn_typ, 'UniformOutput', false);

% Sometimes Excel turns Naming event codes into calendar dates which is
% then read into Matlab. If this happens, this block fixes that.
fix = find(cellfun(@(x) contains(x{1}, '/'), goodsplit));
if sum(fix) > 0
    bad = goodsplit(fix);
    bad = cellfun(@(x) char(x), bad, 'un', 0);
    bad_sep = cellfun(@(x) strsplit(x, '/'), bad, 'un', 0);
    temp = {};
    for ii = 1:length(fix)
        
        b = bad_sep{fix(ii)};
        if mod(str2double(b{3}), 2) == 0    
            b{3} = '0';
        else
            b{3} = '1';
        end
        bad_sep(fix(ii)) = {b};
    end
    goodsplit(fix) = bad_sep;
    bad_evn_patch = cellfun(@(x) strjoin(x, '-'), bad_sep, 'un', 0);
    evn_fix = find(cellfun(@(x) contains(x, '/'), evn_typ));
    for ii = 1:length(evn_fix)
        evn_typ(evn_fix(ii)) = bad_evn_patch(ii);
    end
end

id = cellfun(@(x) x(typ_idx), goodsplit);
keyset = unique(id);

Etype = containers.Map;

for k = 1:length(keyset)
    
    if ~exist([stim_pth focus_typ keyset{k}], 'var')
        mkdir([stim_pth focus_typ keyset{k} '/Channel Events/']);
        mkdir([stim_pth focus_typ keyset{k} '/plots - events/']);
        mkdir([stim_pth focus_typ keyset{k} '/event times/']);
    end

    if ~exist([resp_pth focus_typ keyset{k}], 'var')
        mkdir([resp_pth focus_typ keyset{k} '/Channel Events/']);
        mkdir([resp_pth focus_typ keyset{k} '/plots - events/']);
        mkdir([resp_pth focus_typ keyset{k} '/event times/']);
    end
    
    % Might not need this object. Keeping it in for now just in case.
    %Etype(char(keyset(k))) = good_evn_typ(cellfun(@(x) contains(x, char(keyset(k))), id));
    
    focus_evn_typ = good_evn_typ(cellfun(@(x) contains(x, char(keyset(k))), id));
    focus_evns = good_evns(ismember(good_evn_typ, focus_evn_typ));
    
    save([stim_pth focus_typ keyset{k} '/event times/' focus_typ '_events.mat'], 'focus_evns', 'focus_evn_typ')
    save([resp_pth focus_typ keyset{k} '/event times/' focus_typ '_events.mat'], 'focus_evns', 'focus_evn_typ')
end




while true
    disp('  ')
    disp('Focused HGA:')
    lock_typ = input('Enter S for Stimulus Locked Analysis or R for Response Locked analysis (Q to quit)\n--> ', 's');
    if strcmpi(lock_typ, 's')
        load([stim_ALL_pth 'TvD/TvD.mat'])
        lock_pth = stim_pth;
    elseif strcmpi(lock_typ, 'r')
        load([resp_ALL_pth 'TvD/TvD.mat'])
        lock_pth = resp_pth;
    end
    
    chansHG = string(TvD(:,2));
    chansALL = string(glab_r)';
    gdat_HG = gdat_r(ismember(chansALL, chansHG), :);
    EEGhfb = make_EEG(gdat_HG, TvD(:,2), srate, evns, evn_typ, -1, [SUBID '_' task]);

    
    if strcmpi(lock_typ, 'q')
        break
    elseif ~(strcmpi(lock_typ, 's') || strcmpi(lock_typ, 'r'))
        continue
    else
        msg = sprintf('Here are all types of focus events for %s task\n %s:', task, focus_typ);
        disp(msg)
        t = '';
        for k = 1:length(keyset)
            t = sprintf('%s  %s', t, char(keyset(k)));
        end
        disp(t)
        
        sub_keyst = input('Select which Event types you want to analyze\n--> ', 's');
        sub_keyst = strsplit(sub_keyst);
        if strcmpi(sub_keyst{1}, 'all')
            sub_keyst = keyset;
        end
        
        ce = input('Do you want to run sd_channel_events.m? (y/n)\n--> ', 's');
        
        hfb_chans_all = {};
        for k = 1:length(sub_keyst)
            foc_nm = [focus_typ sub_keyst{k}];
            ch_foc_pth = [lock_pth foc_nm '/'];
            load([ch_foc_pth 'event times/' focus_typ '_events.mat'])
            
            
            msg = sprintf('Channel Events for %s: %s', focus_typ, num2str(k));
            disp('  ')
            disp(msg)
            
            if strcmp(ce, 'yes') || strcmp(ce, 'y')
                sd_channel_events_ud(EEGhfb, focus_evns, lower(lock_typ), ch_foc_pth, ref, foc_nm) 
            end
            
            cd([ch_foc_pth 'Channel events/'])
            foc_mats = dir('*.mat');
            foc_mats = {foc_mats.name};
            
            for ii = 1:length(foc_mats)
                pchan = strsplit(foc_mats{ii}, '_');
                pchan = pchan{3};
                if ~exist([lock_pth 'channel_' pchan], 'dir')
                    mkdir([lock_pth 'channel_' pchan])
                end
                
                copyfile(foc_mats{ii}, [lock_pth 'channel_' pchan '/' foc_mats{ii}]);
                
            end
        end
        
        if ~exist([lock_pth 'Channel HGA Plots by Category/'], 'dir')
            mkdir([lock_pth 'Channel HGA Plots by Category/']);
        end
        
        cd(lock_pth)
        chan_dirs = dir('channel_*');
        chan_dirs = {chan_dirs.name};
        
        for ii = 1:length(chan_dirs)
            plot_by_focus([lock_pth chan_dirs{ii}], task)
            cd([lock_pth chan_dirs{ii}])
            fig = dir('*.jpeg');
            copyfile(fig.name, [lock_pth 'Channel HGA Plots by Category/' fig.name]);
        end
        
    end
end

s = input('\nDo you want to save your work? (y/n)\n--> ', 's');
if strcmp(s, 'yes') || strcmp(s, 'y')
    save([df_dir SUBID '_' task '_dat.mat'], 'EEG')
end









































