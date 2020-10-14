function generate_connectivity_maps(subjs_dir, study, ref, locks, bands, atlas, abr)

ar_ord = 14;
ba_init = 15;

xl_dir = sprintf('%s/Excel Files',subjs_dir);
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end

if contains(xl_dir, 'San_Diego')
    subjs = dir(sprintf('%s/sd*', subjs_dir));
else
    subjs = dir(sprintf('%s/pt*', subjs_dir));
end
subjs = {subjs.name};

for p = 1:length(subjs) % loop thru patients
subj = subjs{p};
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
    for lockc = locks % loop thru time locks
        lock = char(lockc);
    for bandc = bands % loop thru frequency bands
        band = char(bandc);
        cmpth = sprintf('%s/thesis/plots/%s/connectivity_maps', subjs_dir, study);
        dpth = sprintf('%s/thesis/data/%s/adjacency_matricies', subjs_dir, study);
        my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        my_mkdir(dpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        
        dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
        cd(dat_dir)
        dfiles = dir('*_GRAY.mat');
        dfiles = {dfiles.name}; % all stimuls event files
        
        if abr % For connectivity maps
            xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
            loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
        else
            loc = [];
        end
        
        ba = ba_init;      
        S = 0;
        lS = [];
        fS = [];
        BA = [];
        lBA = [];
        fBA = [];
        fprintf('\n%s %s %s\n', subj, lock, band)
        for ii = 1:length(dfiles) % loop thru stimulus event files
            
            fname = dfiles{ii}; % file name
            fsplt = strsplit(fname, '_');
            evn_nm = fsplt{4}; % event name
            evn_nm = erase(evn_nm,'_GRAY.mat');
            fprintf('%i %s\n', ii, evn_nm)
            if ~strcmp(fname(1),'.')  % avoid hidden files and singleton sig data
                load(fname, 'evn_seg')
                dat = evn_seg;
                if size(dat,1) <= 2
                    break
                end
                if ii == 1
                    [stp, tol] = init_stepsize(dat, ba, ar_ord, S);
                end

                [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, stp, tol, S, BA);
                sparsity = S(end);
                ba = BA(end);
                A = gl_ar(dat, ba, ar_ord);
                plot_connectivity_map(A, subj, ref, lock, band, cmpth, evn_nm, loc, 'sparsity', sparsity, 'ar', ar_ord);

                % Save adjaceny matrix (A)
                save(sprintf('%s/%s_%s_%s_%s_%s_adjaceny.mat', dpth, subj, ref, lock, band, evn_nm), 'A');


                lS = [lS length(S)];
                fS = [fS sparsity];
                lBA = [lBA length(BA)];
                fBA = [fBA ba];

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
        end


    end
    end
end
end