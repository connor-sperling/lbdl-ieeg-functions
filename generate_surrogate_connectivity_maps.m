function generate_surrogate_connectivity_maps(subjs_dir, xl_dir, study, ref, locks, bands, ztol, atlas)

ar_ord = 14;
ba_init = 15;
M = 2;

subjs_sd = dir(sprintf('%s/sd*', subjs_dir)); subjs_sd = {subjs_sd.name};
subjs_m  = dir(sprintf('%s/pt*', subjs_dir)); subjs_m  = {subjs_m.name};

if ~isempty(subjs_sd)
    subjs = subjs_sd;
else
    subjs = subjs_m;
end

dpth = sprintf('%s/thesis/undirected_connectivity/surrogate/%s/adjacency_matricies', subjs_dir, study);
my_mkdir(dpth, '*.mat')

for p = 1:length(subjs) % loop thru patients
subj = subjs{p};
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
    study_only = strsplit(study, '-');
    study_only = study_only{1};
    eeg_file = sprintf('%s/%s/data/%s_%s_%s_dat.mat', subjs_dir, subj, subj, study_only, ref);
    load(eeg_file, 'EEG')
    sig_lab = {EEG.chanlocs.labels}';
    for lockc = locks % loop thru time locks
        lock = char(lockc);
    for bandc = bands % loop thru frequency bands
        band = char(bandc);
        loc = readtable(sprintf('%s/significant_%s_%s_%s_%s_%s_localization.xlsx',xl_dir,study,ref,lock,band,atlas));

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
            loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
            shift = randi([1001, 2999],1,1);
            while any(X == shift)
                shift = randi([1001, 2999],1,1);
            end
            X(m) = shift;

            ba = ba_init;      
            S = 0;
            BA = [];
            
            fprintf('\n  m = %i\n', m)
            [evn_seg, evn] = segment_channels_per_event_surrogate(EEG, {}, study, shift);
            
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
                fprintf('%i  ', ii)
                if ii == 1
                    [stp, tol] = init_stepsize(dat, ba, ar_ord, ztol, S);
                end
                [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, ztol, stp, tol, S, BA);
                ba = BA(end);
                A_deck(:,:,ii) = gl_ar(dat, ba, ar_ord);
            end
            save(sprintf('%s/%s_%s_%s_%s_shift_%i_surrogate.mat', dpth, subj, ref, lock, band, shift),'A_deck','evn','sig_lab');
        end


    end
    end
end
end