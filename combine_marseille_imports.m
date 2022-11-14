
clear
clc

% e1 = 'pt22_DV-seq1_import.mat';
e1 = 'pt22_DV_RAW_monopolar_dat.mat';
e2 = 'pt22_DV-seq3_import.mat';

sdir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_Marseille/Subjs';

esplt = strsplit(e1, '_');
subj = esplt{1};
task = strsplit(esplt{2}, '-');
task = task{1};

cd(sprintf('%s/%s/data', sdir, subj))


load(e1);
EEG1 = EEG;

load(e2);
EEG2 = EEG;


Ns = size(EEG1.data, 2);

EEG1.data = [EEG1.data EEG2.data];

Ne = length({EEG1.event.latency});

lat2 = Ns + [EEG2.event.latency]';
dur2 = {EEG2.event.duration}';
chan2 = {EEG2.event.channel}';
bvt2 = {EEG2.event.bvtime}';
bvm2 = {EEG2.event.bvmknum}';
typ2 = {EEG2.event.type}';
cod2 = {EEG2.event.code}';
ur2 = {EEG2.event.urevent}';


for jj = 1:length(lat2)
   EEG1.event(Ne+jj).latency = lat2(jj);
   EEG1.event(Ne+jj).duration = dur2{jj};
   EEG1.event(Ne+jj).channel = chan2{jj};
   EEG1.event(Ne+jj).bvtime = bvt2{jj};
   EEG1.event(Ne+jj).bvmknum = bvm2{jj};

   EEG1.event(Ne+jj).type = typ2{jj};
   EEG1.event(Ne+jj).code = cod2{jj};
   EEG1.event(Ne+jj).urevent = ur2{jj};
end
EEG1.urevent = EEG1.event;
EEG1.pnts = size(EEG1.data, 2);
EEG1.times = 1:size(EEG1.data, 2);
com2 = strsplit(EEG2.comments);
eeg2 = char(com2(cellfun(@(x) contains(x, 'eeg'), com2)));
EEG1.comments = [EEG1.comments '/' eeg2];
EEG = EEG1;
EEG.setname = sprintf('%s_%s', subj, task);
if isfield(EEG,'importfiles')
    EEG.importfiles = [EEG.importfiles, {e2}];
else
    EEG.importfiles = {e1,e2};
end

svfn = sprintf('%s/%s/data/%s_%s_RAW_monopolar_dat.mat', sdir, subj, subj, task);
save(svfn, 'EEG');
