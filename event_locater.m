function [gdat, stimos, jit, xrng, yrng] = event_locater(gdat, glab, Rec, jitter)  

    trig_idx = find(cellfun(@(x)isequal(x,'TRIG'),glab));
    trigchan = gdat(trig_idx,:);
    figure
    plot(trigchan)
    while true   
        trim_rng = input('\nEnter the min and max of your desired x-axis range\n   Format: [min, max]\n   Type - Reset to recover original data range\n          0 to continue and save\n--> ', 's');
        if strcmp(trim_rng(1), '[')
            trim_rng = erase(trim_rng, ["[", "]"]);
            trim_rng = str2double(strsplit(trim_rng, ','));
            break
        else
            continue
        end           
    end

    gdat = gdat(:,trim_rng(1):trim_rng(2));
    trigchan = trigchan(trim_rng(1):trim_rng(2));
    xrng = trim_rng;
    figure
    plot(trigchan)
    
    evns_value_rng = input('\nEnter y-axis range that captures stimulus onset (middle) spikes in plot\nIf you wish to reset the range, type Y at the next prompt\n   Format: [min, max]\n--> ');
    yrng = evns_value_rng';
    stimos = find(trigchan > evns_value_rng(1) & trigchan < evns_value_rng(2));
    de = diff(stimos);
    unique_msk = [true de ~= 1];
    unique_msk(end) = [];
    stimos = stimos(unique_msk);
    stimos = stimos';
    
    % If analysis of data depends on the jitter between fixation onset and
    % stimulus onset, mark '1' for jitter when calling the function to set
    % indicies of fixation time and calculate jitter times. Otherwise '0'
    if jitter == 1
        evns_value_rng = input('\nEnter y-axis range that captures fixation onset (first) spikes in plot\nIf you wish to reset the range, type Y at the next prompt\n   Format: [min, max]\n--> ');
        if length(evns_value_rng) == 4
            fixos = find((trigchan > evns_value_rng(1) & trigchan < evns_value_rng(2)) | (trigchan > evns_value_rng(3) & trigchan < evns_value_rng(4)));
        elseif length(evns_value_rng) == 2
            fixos = find((trigchan > evns_value_rng(1) & trigchan < evns_value_rng(2)));
        end
        de = diff(fixos);
        unique_msk = [true de ~= 1];
        unique_msk(end) = [];
        fixos = fixos(unique_msk);
        fixos = fixos';
        if length(evns_value_rng) == 4
            fixos(1) = [];
        end
    end
    
    if exist('fixos', 'var')
        msg = sprintf('\nThere are %d stimulus events and %d fixation events in your selected data.\nNot correct? Type Reset to re-select x and y ranges (C to continue)\n--> ', length(stimos), length(fixos));
    else
        msg = sprintf('\nThere are %d stimulus events in your selected data.\nNot correct? Type Reset to re-select x and y ranges (C to continue)\n--> ', length(stimos));
    end
    
    reset = input(msg, 's');
    if strcmpi(reset, 'reset')
        gdat = Rec;
        [gdat, stimos, xrng, yrng] = event_locater(gdat, glab, Rec, 0);
    end
    
    if jitter == 1
        jit = stimos - fixos;
    else
        jit = nan;
    end
    
    xrng = xrng';
end
