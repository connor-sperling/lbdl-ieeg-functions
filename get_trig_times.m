function triggerget_trig_times(subj)

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


    %% Find trigger st/stp indices
    st = true;
    k = 0;
    j = 0;
    evns = [];

    for ii = 1:length(trigchan)
        if ismember(trigchan(ii), trig_vals) && st == true
            k = k + 1;
            evns(1,k) = ii;
            st = false;
        elseif ii == length(trigchan) && ismember(trigchan(ii), trig_vals) && st == false
            j = j + 1;
            evns(2,j) = ii;
        elseif ismember(trigchan(ii), trig_vals) && trigchan(ii) ~= trigchan(ii + 1) && st == false
            j = j + 1;
            evns(2,j) = ii;
            st = true;
        end
    end
    evns = evns(:, diff(evns) < 10000);
    save(fname, 'evns');


    %% Check that the value at each event index is in the trigger value list
    in_tvals = [];
    for ii = 1:2
        for jj = 1:size(evns,2)
            in_tvals = [in_tvals ismember(trigchan(evns(ii,jj)), trig_vals)];
        end
    end

    % if b = 0, all 'evns' are trigger value st/stp indicies
    b = 2*size(evns,2)-sum(in_tvals)




















