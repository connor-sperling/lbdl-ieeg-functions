function [ndat, nlab, rdat, removed] = remove_channels(dat, lab, chan_no, rdat, removed)    
    ret_orig = 0;
    for n = chan_no
        if n > 0 && n <= length(lab)
            chan = lab{n};
            lab{n} = 'x';
            if isempty(removed)
                removed = {chan};
            else
                removed = [removed;  {chan}];
            end
        else
            msg = sprintf('Channel #%d is not in range of channel numbers', n);
            disp(msg)
            ret_orig = 1;
            break
        end
    end
    ndat = dat;
    nlab = lab;
    if ~ret_orig
        rdat = [rdat; ndat(chan_no,:)];
        ndat(chan_no,:) = [];
        nlab = {lab{~strcmp(lab, 'x')}};

    end
end