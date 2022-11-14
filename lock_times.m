function [st_tm, en_tm, begin_tm, second_mrk, abvnm] = lock_times(lock, rtm)

    switch lock
        case 'resp'
            abvnm = 'RL';
            begin_tm = -1250;
            st_tm = -1250;
            en_tm = 750;
            an_st_tm = -750;
            an_en_tm = 750;
            second_mrk = -mean(rtm);
        case 'stim'
            abvnm = 'SL';
            begin_tm = -1000;
            st_tm = -400;
            en_tm = 1600;
            second_mrk = mean(rtm);
    end
    
    switch EEG.lock{end}
        case 'resp'        
            st_tm = -1250;
            an_st_tm = -750;
            an_en_tm = 750;
            en_tm = 750;
            second_mrk = -mean(resp);
            
        case 'stim'
            st_tm = -1000;
            an_st_tm = 0;
            an_en_tm = 1000;
            en_tm = 1600;
            second_mrk = mean(resp);
    end
end