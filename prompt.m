function ipt = prompt(pmt, varargin)

    switch pmt
        
        case 'location'
            ipt = '';
            while ~strcmpi(ipt,'San Diego') && ~strcmpi(ipt,'SD') && ~strcmpi(ipt,'Marseille') && ~strcmpi(ipt,'M')
                ipt = input('\nChoose San Diego or Marseille\n--> ', 's');
            end
            
            if strcmpi(ipt,'San Diego') || strcmpi(ipt,'SD')
                ipt = 'San_Diego';
            elseif strcmpi(ipt,'Marseille') || strcmpi(ipt,'M')
                ipt = 'Marseille';
            end
            
        case 'define subject'
            subjs_dir = varargin{1};
            pts = varargin{2};
            location = varargin{3};
            while true  
                ipt = lower(input('\nSubject ID: ', 's'));
                if any(cellfun(@(x) contains(x,ipt), pts))
                    break
                else
                    msg = sprintf('\n%s does not have a folder in the directory: %s\nWould you like to make folders for %s? (y/n)\n--> ', ipt, subjs_dir, ipt);
                    ipt = input(msg, 's');
                    if strcmp(ipt, 'y') || strcmp(ipt, 'yes')
                        mkdir([subjs_dir ipt '/analysis/'])
                        mkdir([subjs_dir ipt '/data/'])
                        mkdir([subjs_dir ipt '/Data Files/'])
                        break
                    end
                end
            end
            
            
        case 'insuff data'
            disp('Looks like there is insufficient data in this patients data files directory')
            disp('Please select an appropriate Rec.mat file or .EDF file for this patient.')
            disp('Loading the patient .EDF file will return a corresponding HDR and REC file.')
            
            
            
        case 'choose file'
            full_files = varargin{1};
            disp('  ')
            disp('Data files found:')
            for ii = 1:size(full_files,1)
                msg = sprintf('\t%d. %s ', ii, full_files(ii,:));
                disp(msg)
            end
            while true
                ipt = input('\nChoose the number of the .mat you would like to proceed with: ');

                if sum(ipt == 1:size(full_files,1)) == 1
                    break
                end
            end
            
        
        case 'research study'
            ipt = input('\nChoose a name for the research study this data is for.\n--> ', 's');
            
           
        case 'disp event labels'
            evn = varargin{1};
            disp('  ')
            disp('Here are some of the channels from this data:')
            evn_disp = char([evn' {'   .', '   .', '   .'}]);
            disp(evn_disp([1:5, size(evn_disp,1)-2:size(evn_disp,1)],:))
            ipt = '';
            
        case 'disp channel labels'
            glab = varargin{1};
            disp('  ')
            disp('Here are some of the channels from this data:')
            glab_abbv_disp = char([glab {'   .', '   .', '   .'}]);
            disp(glab_abbv_disp([1:5, size(glab_abbv_disp,1)-2:size(glab_abbv_disp,1)],:))
            ipt = '';
            
            
        case 'fs'
            ipt = input('\nEnter the sampling rate: ');
            
            
        case 'task name'
            taskbank = varargin{1};
            while true
                ipt = input('\nEnter the task name: ', 's');
                iptchk = ipt;
                iptchk(regexp(iptchk,'\d*')) = [];
                if contains(taskbank, iptchk)
                    break
                end
            end
            
            
        case 'Choose seq number'
            disp('  ')
            disp(varargin{1})
            disp('  ')
            disp(varargin{2})
            disp('  ')
            ipt = input('\nChoose the Seq or Liste identifier\n--> ', 's');
            
            
        case 'choose identifiers'
            header = varargin{1};
            disp('  ')
            disp([char(ones(length(header),1) * '     ') char(header)])
            ipt = input('\nAll possible event identifiers are displayed. Choose as many as you would like, separated by spaces.\n--> ', 's');
            ipt = strsplit(ipt);
            while true
                for ii = 1:length(ipt)
                    if ~any(cellfun(@(x) strcmp(x, ipt{ii}), header))
                        ipt = input(sprintf('\n%s is not a valid identifier, please try again\n--> ', ipt{ii}), 's');
                        ipt = strsplit(ipt);
                        break
                    end
                end
                
                if ~isempty(ipt{ii})
                    if ii == length(ipt)
                        break
                    end
                end
            end
            
            
        case 'remove channels'
            glab_r = varargin{1};
            disp('  ')
            disp('------------------------------------')
            disp([num2str(transpose(1:length(glab_r))) char(ones(length(glab_r),1) * '.  ') char(glab_r)])
            msg = sprintf('\nEnter numbers of any channels you wish to remove\n   Format: array format - i.e. 1:10 or [1:5 19 20:23]\n   Type - 0 to continue\n\nWarning - This cannot be undone.');
            disp(msg)
            while true
                ipt = input('\n--> ');
                if min(ipt) >= 0 && max(ipt) <= length(glab_r)
                    break
                else
                    disp('  ')
                    disp('Not a valid range. Please try again')
                end

            end
            
        case 'duplicate research'
            msg = sprintf('\nThe current reference type is %s. Changing the reference type will avoid overwriting the current data with this research name.\nChoose the reference type you would like to proceeed with.\n--> ', varargin{1});
            ipt = '';
            while ~strcmp(ipt, 'monopolar') && ~strcmp(ipt, 'mono') && ~strcmp(ipt, 'bipolar') && ~strcmp(ipt, 'bi')
                ipt = input(msg, 's');
            end
            
            
        case 'choose ref type'
            ipt = '';
            while ~strcmp(ipt, 'monopolar') && ~strcmp(ipt, 'mono') && ~strcmp(ipt, 'bipolar') && ~strcmp(ipt, 'bi')
                ipt = input('Would you like to work with monopolar or bipolar data?', 's');
            end
            
            
        case 'ecrej header'
            evn = varargin{1};
            evn_idc = varargin{2};
            
            len_et = length(evn);
            
            disp('  ')
            disp('    Events      Event idx')
            disp([char(ones(len_et,1) * '     ')  char(evn) char(ones(len_et,1) * '     ') num2str(evn_idc)])

            str = ['\nTo REJECT an event or a channel\n'...
                   '   Type -      "Event"      followed by any number of event names.\n'...
                   '        -  "Event Contains" followed by a common phrase within the name to reject multiple events of the same type.\n'...
                   '        -     "Channel"     followed by any number of channel names found in the plot.\n'...
                   '\nTo REPLACE an event or a channel\n'...
                   '   Type -  "Event Replace"  followed by any number of events you want to remove from the rejection list\n'...
                   '        - "Channel Replace" followed by any number of channels you want to remove from the rejection list\n'...
                   '                                 (channel data will be restored at the bottom of the new plot)\n'... 
                   '\nTo show the events or channels that have been marked for rejection\n'...
                   '   Type -   "Show Events"\n'...
                   '        -  "Show Channels"\n'...
                   '\nTo view the rejected channels\n'...
                   '   Type -   "View Reject"\n'...
                   '\nTo display this message again\n'...
                   '   Type -      "Help"\n'...
                   '\nTo end this session, enter "0"\n\n--> '];
            ipt = input(str, 's');
           
            
        case 'ecrej help'
            msg = sprintf(['\nTo REJECT an event or a channel\n'...
                   '   Type -      "Event"      followed by any number of event names.\n'...
                   '        -  "Event Contains" followed by a common phrase within the name to reject multiple events of the same type.\n'...
                   '        -     "Channel"     followed by any number of channel names found in the plot.\n'...
                   '\nTo REPLACE an event or a channel\n'...
                   '   Type -  "Event Replace"  followed by any number of events you want to remove from the rejection list\n'...
                   '        - "Channel Replace" followed by any number of channels you want to remove from the rejection list\n'...
                   '                                 (channel data will be restored at the bottom of the new plot)\n'... 
                   '\nTo show the events or channels that have been marked for rejection\n'...
                   '   Type -   "Show Events"\n'...
                   '        -  "Show Channels"\n'...
                   '\nTo view the rejected channels or the excess channels\n'...
                   '   Type -   "View Reject"\n'...
                   '        -   "View Excess"\n'...
                   '\nTo display this message again\n'...
                   '   Type -      "Help"\n'...
                   '\nTo end this session, enter "0"']);
            disp(msg)
            
            
        case 'arrow'
            ipt = input('\n--> ', 's');
                   
            
        case 'rejected events'
            evn_rej = varargin{1};
            len_er = length(evn_rej);
            
            if ~isempty(evn_rej)
                disp('  ')
                disp('The following events have already been marked to reject:')
                disp('  ')
                disp(' Event name')
                disp([char(ones(len_er,1) * '     ') char(evn_rej)])
                disp('  ')
            else
                disp('  ')
                disp('No events have been rejected so far')
                disp('  ')
            end
            
            
        case 'rejected channels'
            chan_rej = varargin{1};
            len_cr = length(chan_rej);
            
            if ~isempty(chan_rej)
                disp('  ')
                disp('The following channels have been rejected:')
                disp('  ')
                disp([char(ones(len_cr,1) * '     ') char(chan_rej)])
                disp('  ')
            else
                disp('  ')
                disp('No channels have been rejected so far')
                disp('  ')
            end
              
            
        case 'skipping event'
            evn = varargin{1};
            disp('  ')
            msg = sprintf('Event %s has already been selected for rejection. Skipping...', evn);
            disp(msg)
            
            
        case 'notch filt freq'
            if nargin == 2
                filts = varargin{1};
                msg = sprintf('\nThese are the notch filters that have been placed on your data:\n');
                for n = 1:length(filts)
                    msg = sprintf('%s  %d Hz', msg, filts(n));
                end
                msg = sprintf('%s\nWould you like to filter again? Enter frequency in Hz: (-1 for None)\n--> ', msg);
            else
                msg = sprintf('\nApply notch filter? Enter frequency in Hz: (-1 for None)\n--> ');
            end
            ipt = input(msg);
            
            
        case 'pick subjs'
            subjs = varargin{1};
            len_s = length(subjs);
            disp('  ')
            disp('Here are all of the subjects in your directory:')
            disp([char(ones(len_s,1) * '     ')  char(subjs)])
            msg = sprintf('\nChoose which subjects you would like to analyze. (All - to analyze every possible subject)\n--> ');
            ipt = lower(input(msg, 's'));
            
            
        case 'pick study'
            tasks = varargin{1};
            tdisp = sprintf('\nThe available Language Tasks are:\n  %s,', tasks{1});
            for ii = 2:length(tasks)
                if ii == length(tasks)
                    tdisp = sprintf('%s %s', tdisp, tasks{ii});
                else
                    tdisp = sprintf('%s %s,', tdisp, tasks{ii});
                end
            end
            disp(tdisp)
            swch = 1;
            
            while swch
                msg = sprintf('\nChoose any number of tasks followed by "_<research name>"\n--> ');
                ipt = input(msg, 's');
                cipt = strsplit(ipt);
                for ii = 1:length(cipt)
                    tipt = strsplit(cipt{ii}, '_');
                    if all(~cellfun(@(x) strcmpi(x, tipt{1}), tasks))
                        swch = 1;
                        break
                    else
                        swch = 0;
                    end
                    
                end
                
            end
            

        case 'study condition'
            ipt = '';
            while ~strcmpi(ipt,'T') && ~strcmpi(ipt,'I') && ~strcmpi(ipt,'together') && ~strcmpi(ipt,'independently')
                ipt = input('\nWould you like to analyze the conditions together ("T") or independently ("I")?\n--> ', 's');
            end
            
            if strcmpi(ipt, 'T') || strcmpi(ipt,'together')
                ipt = 0;
            else
                ipt = 1;
            end
            
            
        case 'pick band'
            ipt = '';
            while true   
                msg = sprintf('\nWould you like to study High Frequency Band (HFB) activity, Local Field Potential (LFP) activity, or both?\n--> ');
                ipt = upper(input(msg, 's'));
                if ~strcmpi(ipt, 'HFB') && ~strcmpi(ipt, 'LFP') && ~strcmpi(ipt, 'both') && ~strcmpi(ipt, 'raw')
                    disp(' ')
                    disp('Enter HFB for High Frequency Band, LFP for Local Field Potential, both for both, or none for no filter.')
                else
                    break
                end
            end
            
            
        case 'reference'
            ipt = '';
            while  ~strcmpi(ipt, 'bipolar') && ~strcmpi(ipt, 'monopolar') && ~strcmpi(ipt, 'monopolar-AR')
                ipt = lower(input('\nWould you like to work with monopolar or bipolar referenced data?\n--> ','s'));
            end
            
            
        case 'processing info'
            subj = varargin{1};
            task = varargin{2};
            study = varargin{3};
            lock = varargin{4};
            nchan = varargin{5};
            nevn = varargin{6};
            norig = varargin{7};
            
            msg = sprintf('\nProcessing: %s, %s task, %s analysis, %s\n            Analysis will include %d channels over %.2f%% of the original stimulus events.', subj, task, study, lock, nchan, 100*nevn/norig);
            disp(msg)
            
            
        case 'study'
            while true
                ipt = upper(input('\nLFP and HG frequency bands are currently supported for analysis. \nWhich would you like to proceed with? (Q to quit)\n--> ', 's'));
                if strcmp(ipt, 'HG') || strcmp(ipt, 'LFP') || strcmp(ipt, 'Q')
                    break
                end
            end
            
            
        case 'lock type'
            while true
                lt = input('\nEnter S for Stimulus Locked Analysis or R for Response Locked analysis\n--> ', 's');
                if strcmpi(lt, 's')
                    ipt = 'Stimulus Locked';
                    break
                elseif strcmpi(lt, 'r')
                    ipt = 'Response Locked';
                   break
                end
            end
           
            
        case 'running ALL prep'
            msg = sprintf('\n%s: Gathering all channel data over all event regions', varargin{1});
            disp(msg)
            
            
        case 'running sigchan'
            msg = sprintf('\n%s: Running frequency band analysis', varargin{1});
            disp(msg)
            
            
        case 'no results'
            msg = sprintf('\nFBA for %s - %s produced no results\nMoving on....', varargin{1}, varargin{2});
            disp(msg)
            
            
        case 'naming fba'
            msg = sprintf('\nGrouping and analyzing stimulus events by position in category');
            disp(msg)
            
            
        case 'stroop fba'
            msg = sprintf('\nGrouping and analyzing stimulus events by congruency with respect to Stroop task.\nData will be analyzed and plotted over events that are in one of 8 conditions.\ni.e. Congruent in color while in Color stroop task (cCc), Incongruent in color while in Color Stroop task (cIc), Congruent in space while in Spatial Stroop task (sCs), etc.');
            disp(msg)

            
        case 'stroop evn prep'
            pos = '';
            if isequal(varargin{2}, 'Beg')
                pos = '1st';
            elseif isequal(varargin{2}, 'End')
                pos = '2nd';
            end
            msg = sprintf('\n(%d/16) Processing %s%s%s events within the %s 20 events of each block:\n', varargin{1}, varargin{3}, varargin{4}, varargin{5}, pos);
            disp(msg)
            
            
        case 'stroop plot'
            disp(' ')
            disp('Plotting...')
            
            
            
        case 'naming evn analysis'
            msg = sprintf('\n    Processing in groups of %s', varargin{1});
            disp(msg)
            
            
        case 'ALL or condition'
            ipt = '';
            while ~strcmp(ipt, 'ALL') && ~strcmp(ipt, 'condition')
                ipt = input('\nWrite text file from events in the ALL or condition category?\n--> ', 's');
            end
            
            
    end
end
