function [seg_sz, xdiv] = dividewindow (total_time, seg_sz, min_sz)


    xdiv = total_time/seg_sz;
    
    if floor(xdiv) == xdiv-0.5
        xdiv = xdiv - 0.5;
    elseif floor(xdiv) ~= xdiv
        wold = seg_sz;
        win_set = min_sz:min_sz:total_time;
        pwins = win_set(rem(total_time,win_set)==0);
        if isempty(pwins)
            error('Cannont find a window size to evenly divide the total time window. Consider resizing this window.')
        end
        ewins = pwins - seg_sz;
        pos_wins = pwins(ewins > 0);
        seg_sz = min(pos_wins);
        if seg_sz == total_time
            [~,win_idx] = min(abs(ewins));
            seg_sz = pwins(win_idx);
        end
        xdiv = total_time/seg_sz;
        msg = sprintf('\nWindow size re-sized to %d ms from %d ms in order to divide the total time, %d ms, evenly.', seg_sz, wold, total_time);
        disp(msg)
    end

end