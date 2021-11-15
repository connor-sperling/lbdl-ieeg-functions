function generate_connectivity_maps_iEa(EEG, subjs_dir, dat_dir, study, ztol)

    info = strsplit(EEG.setname,'_');
    subj = info{1};
    lock = EEG.lock;
    band = EEG.band;
    ref = EEG.ref;
    
    ar_ord = 14;
    ba_init = 15;

    cmpth = sprintf('%s/thesis/undirected_connectivity/plots/%s/connectivity_maps', subjs_dir, study);
    dpth = sprintf('%s/thesis/undirected_connectivity/data/%s/adjacency_matricies', subjs_dir, study);
    my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
    my_mkdir(dpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))

%     dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
%     cd(dat_dir)
%     dfile = dir('*_GRAY.mat');
    dfile = dir(sprintf('%s/*.mat',dat_dir));
    dfile = {dfile.name}; % all stimuls event files
    dfile(cellfun(@(x) strcmp(x(1),'.'), dfile)) = [];
    file = dfile{1};
    load(sprintf('%s/%s',dat_dir,file),'evn_seg','evn','sig_lab')

    N = size(evn_seg,1);
    L = size(evn_seg,3);

    A_deck = zeros(N,N,L);
    ba = ba_init;      
    S = 0;
    BA = [];

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

    end
    save(sprintf('%s/%s_%s_%s_%s_adjaceny.mat', dpth, subj, ref, lock, band),'A_deck','evn','sig_lab');

end