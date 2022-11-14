
fname = strsplit(EEG.filename, '_');
pt = fname{1};
den = erase(fname{2}, '.set');
m = sprintf('\n Saving: %s - %s data', pt, den);
disp(m)

sdir = '/Volumes/LBDL Extern/bdl-raw/iEEG_Marseille/Subjs';


snm = sprintf('%s/%s/Data Files/%s_%s_RAW_monopolar.mat', sdir, pt, pt, den);
save(snm, 'EEG', '-v7.3')
disp(' ')
disp('done')