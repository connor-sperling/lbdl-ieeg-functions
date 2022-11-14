function [Evns, Evnis, Rtms] = modular_evn_split (arg, evn, evni, rtm, varargin)

    filt = false;
    if nargin > 4 && strcmp(varargin{1}, 'filter')
       filt_arg = varargin{2}; 
       filt = true;
    end
    
    cond_set = {};
    arg_nums = [];
    arg_sp = strsplit(arg, '-');
    k = 0;
    evn_sp = cellfun(@(x) strsplit(x, '-'), evn, 'uni', 0);
    
    for ii = 1:length(arg_sp)
        if strcmp(arg_sp{ii}, 'x')   
            k = k + 1;
            arg_nums = [arg_nums ii];   

            evn_comp = cellfun(@(x) x(ii), evn_sp);
            uq_evn_comp = unique(evn_comp);
            cond_set(k) = {uq_evn_comp};
        end
    end
    
    combs = var_condition_combs(cond_set);
    
    Evns = {}; Evnis = {}; Rtms = {};
    
    for m = 1:size(combs,1)
        sub_evn = evn;
        sub_evni = evni;
        sub_rtm = rtm;
        for n = 1:size(combs,2)
            sub_evn_sp = cellfun(@(x) strsplit(x, '-'), sub_evn, 'uni', 0);
            evn_comp = cellfun(@(x) x(arg_nums(n)), sub_evn_sp);
            msk = cellfun(@(x) strcmp(x, combs{m, n}), evn_comp);

            sub_evn = sub_evn(msk);
            sub_evni = sub_evni(msk);
            sub_rtm = sub_rtm(msk);
        end

        Evns{m} = sub_evn;
        Evnis{m} = sub_evni;
        Rtms{m} = sub_rtm;
    end
    
    if filt
        filt_arg_sp = strsplit(filt_arg, '-');
        tot_arg = length(filt_arg_sp); arg_no = 1:tot_arg;
        filt_msk = cellfun(@(x) ~strcmp(x, '*'), filt_arg_sp);
        filt_args = filt_arg_sp(filt_msk);
        filt_arg_no = arg_no(filt_msk);
        
        for p = 1:length(filt_args)
            
            for i = 1:length(Evns)
                evn_set = Evns{i};
                evni_set = Evnis{i};
                rtm_set = Rtms{i};
                
                evn_sp = cellfun(@(x) strsplit(x, '-'), evn_set, 'uni', 0);
                evn_comp = cellfun(@(x) x(filt_arg_no(p)), evn_sp);
                unq_comp = unique(evn_comp);
                evn_msk = false(size(evn_set));
                for j = 1:length(unq_comp)
                    ev_arg = strrep(filt_args{p}, '*', unq_comp{j});
                    if eval(ev_arg)
                        evn_msk = or(evn_msk, cellfun(@(x) strcmp(x,unq_comp{j}), evn_comp));
                    end
                end
                Evns{i} = evn_set(evn_msk);
                Evnis{i} = evni_set(evn_msk);
                Rtms{i} = rtm_set(evn_msk);
            end
        end
    end


end
