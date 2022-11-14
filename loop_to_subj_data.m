

% Originally written to loop through to all of the 'condition' directories
% and delete the 'mean' file that I forgot to stop making. But this gives
% the general structure to loop through to these directories and do
% anything

subjs_dir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs';
subjs = {'sd09','sd10','sd14','sd18','sd19','sd21'};
locks = {'stim', 'resp'};
bands = {'HFB','LFP'};
ref = 'bipolar';
study = 'Stroop_CIC-MISO';

for s = subjs
    subj = char(s);
    for l = locks
        lock = char(l);
        for b = bands
            band = char(b);
            
            pth = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s',subjs_dir,subj,study,ref,lock,band);
            
            fp = dir(fullfile(pth, '*mean*'));
            del = {fp.name};

            for c = 1:length(del)
                delete(sprintf('%s/%s', pth, del{c}));
            end
            
        end
    end
end
