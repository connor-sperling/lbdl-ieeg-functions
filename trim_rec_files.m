%% Initiate
subj = '05';

%% Set-up
subj_path = sprintf('L:/iEEG_San_Diego/Bipolar Rereferenced Data/SD%sreref/SD%s_origHdrRec/', subj, subj);
fname = sprintf([subj_path 'pt%s_trigtimes.mat'], subj);

cd(subj_path)
d = dir;
files = {d.name};
Rec_nm = files{cellfun(@(x) contains(x,'REC'),files)};
Hdr_nm = files{cellfun(@(x) contains(x,'HDR'),files)};

load(Rec_nm)
load(Hdr_nm)

chan_idx = find(cellfun(@(x)isequal(x,'TRIG'),Hdr.label) == 1);
trigchan = Rec(chan_idx,:);
baseline_idx = find(trigchan == mode(trigchan), 1);
trig_vals = unique(trigchan(trigchan ~= Rec(chan_idx,baseline_idx)), "stable");


%%
big_gap = 4000;
delt = 200;
cut_num = -max(trigchan) + rand(1);

for ii = 2:size(evns,2)
    if evns(1,ii)-evns(2,ii-1) > big_gap && evns(1,ii)-big_gap/2-delt > evns(2,ii-1)+big_gap/2+delt
        trigchan(evns(2,ii-1)+big_gap/2+delt:evns(1,ii)-big_gap/2-delt) = cut_num;
    end
end

trim_trig_chan = trigchan;
Rec_trim = Rec;
Rec_trim(:, trigchan == cut_num) = [];

% save(fname, 'Rec_trim', '-v7.3');