function generate_connectivity_maps(subjs_dir, study, ref, locks, bands, atlas, abr)

opt_sparsity = 0.6;
tol_init = 0.001;
tol_stp = 0.002;
ztol = 0.001;
ba_init = 15;
stp_init = 10;
ar_ord = 14;


xl_dir = sprintf('%s/Excel Files',subjs_dir);
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end
loc_key = readtable(loc_key_file);
loc = []; % for the case when annotate_brain_region = false

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
        cmpth = sprintf('%s/plots/connectivity_maps/%s', subjs_dir, study);
        my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
        
        dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
        cd(dat_dir)
        dfiles = dir('*.mat');
        dfiles = {dfiles.name}; % all stimuls event files
        
        if abr
            xl_nm = sprintf('significant_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
            loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
        end
        
        ba = ba_init;      
        S = 0;
        lS = [];
        fS = [];
        BA = [];
        lBA = [];
        fBA = [];

        for ii = 1:length(dfiles) % loop thru stimulus event files
            stp = stp_init;
            tol = tol_init;
            fname = dfiles{ii}; % file name
            fsplt = strsplit(fname, '_');
            evn_nm = fsplt{4}; % event name
            if ~strcmp(fname(1),'.') % avoid hidden files
                load(fname, 'evn_seg')
                dat = evn_seg;
                sparsity = 0;
                if size(dat) > 1 
                    S_end = ones(1,10);
                    k = 0;
                    while sparsity <= opt_sparsity - tol || sparsity >= opt_sparsity + tol
                        A = gl_ar(dat, ba, ar_ord);

                        sparsity = sum(A(:)<ztol)/length(A(:)); 

                        S = [S sparsity];
                        S_end = [S_end(2:10) sparsity];
%                         zmSend = S_end - mean(S_end);
                        BA = [BA ba];
                        Sz = S - opt_sparsity;
                        if abs(Sz(end))+abs(Sz(end-1)) ~= abs(Sz(end)+Sz(end-1))
                            stp = stp/2;
%                         elseif sum(diff(S_end)) == 0
%                             stp = stp+1;
%                         else
%                             stp = stp_init;
                        end

                        ds = sparsity-opt_sparsity;
                        if ds >= 0 && ba-stp>0
                            ba = ba - stp;
                        else
                            ba = ba + stp;
                        end
                        
                        k = k+1;
                        if k > 100
                            tol = tol + tol_stp;
                        end
                    end
                    ba = BA(end);
                    A = gl_ar(dat, ba, ar_ord);
                    plot_connectivity_map(A, ba, ar_ord, subj, evn_nm, ref, lock, band, cmpth, loc);
                    lS = [lS length(S)];
                    fS = [fS sparsity];
                    
                    lBA = [lBA length(BA)];
                    fBA = [fBA ba];
                end
            end
        end

        % Figures for sparsity control algorithm
%         figure
%         plot(1:length(S)-1,S(2:end), 'linewidth', 1.5)
%         hold on
%         scatter(lS-1, fS, 'x', 'r') 
%         xlabel('iterations')
%         ylabel('sparsity')
%         set(gcf, 'Units','pixels','Position',[100 110 2000 400])
% 
%         figure
%         plot(1:length(BA), BA, 'linewidth', 1.5)
%         hold on
%         scatter(lBA, fBA, 'x', 'r') 
%         xlabel('iterations')
%         ylabel('ba')
%         set(gcf, 'Units','pixels','Position',[100 110 2000 400])
    end
    end
end
end