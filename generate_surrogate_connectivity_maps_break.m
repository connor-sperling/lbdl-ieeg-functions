function generate_surrogate_connectivity_maps_break(subjs_dir, xl_dir, study, ref, locks, bands, ztol, atlas, fs)

ar_ord = 14;
ba_init = 15;
M = 10;
pad_time = 10; % seconds
pad_samp = pad_time*fs;

subjs_sd = dir(sprintf('%s/sd*', subjs_dir)); subjs_sd = {subjs_sd.name};
subjs_m  = dir(sprintf('%s/pt*', subjs_dir)); subjs_m  = {subjs_m.name};

if ~isempty(subjs_sd)
    subjs = subjs_sd;
else
    subjs = subjs_m;
end

blacklist = readtable(sprintf('%s/Break_Times_Blacklist.xlsx',xl_dir));

dpth = sprintf('%s/thesis/undirected_connectivity/surrogate/%s/adjacency_matrices', subjs_dir, study);
% my_mkdir(dpth, '*.mat')
subjs = {'sd09', 'sd10', 'sd14', 'sd18'}; % subjs run 5/9 10:42
for p = 1:length(subjs) % loop thru patients
subj = subjs{p};
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
subj_blacklist = blacklist(cellfun(@(x) strcmp(x, subj), blacklist.subj),:); % get just subj blacklist times
subj_blacklist_set = removevars(subj_blacklist, {'subj'}); % drop subj column
subj_blacklist_set = subj_blacklist_set{:,:}.*fs; % turn table into matrix and turn time data into samples
if exist(stddir, 'dir') % check if study exists for patient
    study_only = strsplit(study, '-');
    study_only = study_only{1};
    
    eeg_file = sprintf('%s/%s/data/%s_%s_%s_dat.mat', subjs_dir, subj, subj, study_only, ref);
    load(eeg_file, 'EEG')
    
    sig_lab = {EEG.chanlocs.labels}';
    all_event = {EEG.event.type}';
    all_event_idc = [EEG.event.latency]';
    
    break_idc = find(contains(all_event,'BREAK'));
    break_endpoints = [all_event_idc(break_idc-1) all_event_idc(break_idc)]; % Nx2 matrix N = # break events
    break_endpoints_pad = [break_endpoints(:,1)+pad_samp break_endpoints(:,2)-pad_samp]; % capture break data 'pad_time' seconds away from any event
    
    while any(diff(break_endpoints_pad,1,2) <= fs)
        pad_time = pad_time-1; % seconds
        if pad_time < 1
            error('There is a problem with the BREAK data. Pad time less than 1 second')
        end
        pad_samp = pad_time*fs;
        break_endpoints_pad = [break_endpoints(:,1)+pad_samp break_endpoints(:,2)-pad_samp];
    end
    for lockc = locks % loop thru time locks
        lock = char(lockc);
    for bandc = bands % loop thru frequency bands
        band = char(bandc);
        loc = readtable(sprintf('%s/significant_%s_%s_%s_%s_%s_localization.xlsx',xl_dir,study,ref,lock,band,atlas));

        if strcmp(subj, 'sd09') && strcmp(lock, 'resp')
            continue
        end
        
        if strcmp(subj, 'sd18') && strcmp(lock, 'stim')
            continue
        end
        
        tvd_file = sprintf('%s/%s/analysis/%s/%s/%s/ALL/TvD/%s/ALL_%s_TvD.mat', subjs_dir, subj, study, ref, lock, band, band);
        load(tvd_file, 'TvD')
        
        % Patch for sd14. The RHB shaft was not localized by Burke but it
        % shows up in the data and it is found significant. The code below
        % removes it but this is a temporary fix as it should be included
        % once it is localized.
        if strcmp(subj, 'sd14') 
            TvD(cellfun(@(x) contains(x, 'RHB'), TvD(:,2)),:) = [];
        end
        
        EEG.lock = lock;
        EEG.band = band;
        
        X = zeros(M, 1);
        fprintf('\n%s %s %s\n',subj,lock,band)
        for m = 1:M
%             sig_lab = TvD(:,2);
%             loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
%             shift = randi([1001, 2999],1,1);
%             while any(X == shift)
%                 shift = randi([1001, 2999],1,1);
%             end
%             X(m) = shift;
% 
            ba = ba_init;      
            S = 0;
            BA = [];
            
            fprintf('\n  m = %i\n', m)
            [evn_seg, evn] = segment_channels_per_event_BREAK(EEG, {}, study, break_endpoints_pad, subj_blacklist_set);
            
%             regions = loc_subj.region;
%             lab_ordered = loc_subj.channel_organized;
%             if length(lab_ordered) == length(sig_lab)
%                 [~,order] = ismember(lab_ordered, sig_lab);
%                 evn_seg = evn_seg(order,:,:);
%                 sig_lab = sig_lab(order);
%             else
%                 error('Table and Data dimensions do not match')
%             end
%             
%             rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
%             region_only = cellfun(@(x) x{2}, rsplt, 'uni', 0);
%             wm_msk = cellfun(@(x) strcmp(x, 'WM') | strcmp(x, 'U') | strcmp(x, 'blanc') | strcmp(x, 'out'), region_only);
%             
%             lab_ordered(wm_msk,:) = [];
%             sig_lab(wm_msk,:) = [];
%             evn_seg(wm_msk,:,:) = [];
%             
%             N = size(evn_seg,1);
%             L = length(evn);
%             if N <= 2
%                 continue
%             end
            N = size(evn_seg,1);
            L = length(evn);
            A_deck = zeros(N,N,L);
            for ii = 1:L % loop thru stimulus event files
                dat = evn_seg(:,:,ii);
                if ii == 1
                    [stp, tol] = init_stepsize(dat, ba, ar_ord, ztol, S);
                end
                [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, ztol, stp, tol, S, BA);
                ba = BA(end);
                A_deck(:,:,ii) = gl_ar(dat, ba, ar_ord);
            end
            save(sprintf('%s/%s_%s_%s_%s_break%i_surrogate.mat', dpth, subj, ref, lock, band, m),'A_deck','evn','sig_lab');
        end


    end
    end
end
end