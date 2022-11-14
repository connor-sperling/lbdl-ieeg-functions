function generate_connectivity_maps(subjs_dir, study, ref, locks, bands, ztol, atlas, abr)

ar_ord = 14;
ba_init = 15;

xl_dir = sprintf('%s/Excel Files',subjs_dir);
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir); % localization key (in excel directory) has all the abbreviations for brain regions
if ~exist(loc_key_file, 'file') % if the localization key is not found, it throws an error and breaks code
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end

% set path to subjects directory
if contains(xl_dir, 'San_Diego')
    subjs = dir(sprintf('%s/sd*', subjs_dir)); 
else
    subjs = dir(sprintf('%s/pt*', subjs_dir));
end
subjs = {subjs.name}; % makes list of subjects found

for p = 1:length(subjs) % loop thru patients
subj = subjs{p}; 
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
    for lockc = locks % loop thru time locks (resp, stim)
        lock = char(lockc);
    for bandc = bands % loop thru frequency bands (HFB LFP)
        band = char(bandc);
        cmpth = sprintf('%s/thesis/undirected_connectivity/plots/%s/connectivity_maps', subjs_dir, study); % path for plotted connectivity maps
        dpth = sprintf('%s/thesis/undirected_connectivity/data/%s/adjacency_matricies', subjs_dir, study); % path for storing the connectivity map data
        
        % makes the directory if it does not exist, if already exists, only the
        % files named with the current subject AND lock AND band are
        % deleted
        my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        my_mkdir(dpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        
        dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band); % path to get the data created from iEEG_analysis
        cd(dat_dir) 
%         dfile = dir('*_GRAY.mat');
        dfile = dir('*.mat'); % gets all of the mat files from the 'dat_dir' directory
        dfile = {dfile.name}; % cleaning up
        dfile(cellfun(@(x) strcmp(x(1),'.'), dfile)) = []; % cleaning up
        file = dfile{1}; % cleaning up
        
        % evn_seg - 3d array of significant electrodes across all events
        %         - N x T x L
        %            - N = number of significant electrodes
        %            - T = 1000ms time window
        %            - L = number of events
        % evn     - names of all of the events
        % sig_lab - this is sort of a misnomer currently because all
        %           electodes are included in this list. The maps are
        %           currenly being made with all electrodes included
        load(file,'evn_seg','evn','sig_lab')
        
        N = size(evn_seg,1); 
        L = size(evn_seg,3);
        if N <= 2 % if there are less than two electrodes, no point in making a connectivity map
            continue % tells matlab to go to the next loop
        end
        
%         For connectivity maps
        if abr % should always be true
            xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
            loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
        else
            loc = [];
        end
        
        A_deck = zeros(N,N,L); % A_deck is a #electrode x #electrode x #event matrix. Stores all event connectivity map for a subject, lock, band combination
        ba = ba_init; 
        S = 0;
        BA = [];
        
%         lS = [];
%         fS = [];
%         lBA = [];
%         fBA = [];
        fprintf('\n%s %s %s\n', subj, lock, band)
        
        for ii = 1:L % loop thru stimulus event files
            dat = evn_seg(:,:,ii);
            evn_nm = evn{ii}; % event name
            fprintf('%i %s\n', ii, evn_nm)

            if size(dat,1) <= 2
                break
            end
            if ii == 1
                [stp, tol] = init_stepsize(dat, ba, ar_ord, ztol, S);
            end

            [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, ztol, stp, tol, S, BA);
            sparsity = S(end);
            ba = BA(end);
            A = gl_ar(dat, ba, ar_ord);
            A_deck(:,:,ii) = A;
%             plot_connectivity_map(A, subj, ref, lock, band, cmpth, loc, ztol, 'event', evn_nm, 'sparsity', sparsity, 'ar', ar_ord);


%             lS = [lS length(S)];
%             fS = [fS sparsity];
%             lBA = [lBA length(BA)];
%             fBA = [fBA ba];

%             %         Figures for sparsity control algorithm
%                     figure
%                     plot(1:length(S)-1,S(2:end), 'linewidth', 1.5)
%                     hold on
%                     scatter(lS-1, fS, 'x', 'r') 
%                     xlabel('iterations')
%                     ylabel('sparsity')
%             %         set(gcf, 'Units','pixels','Position',[100 110 2000 400])
% 
%                     figure
%                     plot(1:length(BA), BA, 'linewidth', 1.5)
%                     hold on
%                     scatter(lBA, fBA, 'x', 'r') 
%                     xlabel('iterations')
%                     ylabel('ba')
%             %         set(gcf, 'Units','pixels','Position',[100 110 2000 400])
%                     close all

        end
        save(sprintf('%s/%s_%s_%s_%s_adjaceny.mat', dpth, subj, ref, lock, band),'A_deck','evn','sig_lab');
    end
    end
end
end