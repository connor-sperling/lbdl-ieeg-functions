
ba = 2000;
q = 47;
study = 'Stroop_EA';
subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs';
% pts = dir(sprintf('%s/sd*', subjs_dir));
% pts = {pts.name};
pts = {'sd14', 'sd18', 'sd19', 'sd21'};
cmpth = sprintf('%s/plots/connectivity_maps/%s', subjs_dir, study);
% my_mkdir(cmpth, '*.png')
for p = 1:length(pts)
    subj = pts{p};
    disp(subj)
    stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
    if exist(stddir, 'dir')
        for refc = {'monopolar', 'monopolar-ar', 'bipolar'}
            ref = char(refc);
            for lockc = {'stim', 'resp'}
                lock = char(lockc);
                for bandc = {'NONE'}
                    band = char(bandc);
                    dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);
                    cd(dat_dir)
                    dfiles = dir('*.mat');
                    dfiles = {dfiles.name};
                    for ii = 1:length(dfiles)
                        fname = dfiles{ii};
                        fsplt = strsplit(fname, '_');
                        if length(fsplt) == 3
                            evn_nm = 'Average';
                        else
                            evn_nm = fsplt{4};
                        end
                        if ~strcmp(fname(1),'.')
                            load(fname, 'evn_seg')
                            if size(evn_seg) > 1
                                A = gl_ar(evn_seg, ba, q, subj, evn_nm, ref, lock, band, cmpth);
                            end
                        end
                    end
                end
            end
        end
    end
end