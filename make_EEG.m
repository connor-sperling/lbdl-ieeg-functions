function EEG = make_EEG(EEG, varargin)

    if nargin == 0
        
        EEG = struct;
        EEG.setname = '';
        EEG.nbchan = nan;
        EEG.trials = 1;
        EEG.pnts = nan;
        EEG.srate = nan;
        EEG.xmin = nan;
        EEG.xmax = nan;
        EEG.times = [];
        EEG.data = [];
        EEG.icaat = [];
        EEG.icawinv = [];
        EEG.icasphere = [];
        EEG.icaweights = [];
        EEG.icachansind = [];
        EEG.chanlocs = struct;
        EEG.urchanlocs = [];
        EEG.chaninfo.plotrad = [];
        EEG.chaninfo.shrink = [];
        EEG.chaninfo.nosedir = '+X';
        EEG.chaninfo.nodatchans = [];
        EEG.chaninfo.icachansind = [];
        EEG.ref = '';
        EEG.eventcode = '';
        EEG.analysis = [];
        EEG.event = [];
        EEG.urevent = [];
        EEG.eventdescription = cell(1,8);
        EEG.epoch = [];
        EEG.epochdescription = cell(0,0);
        EEG.reject = struct;
        EEG.datreject = struct;
        EEG.stats = struct;
        EEG.specdata = [];
        EEG.specicaact = [];
        EEG.splinefile = '';
        EEG.icasplinefile = '';
        EEG.dipfit = [];
        EEG.history = [];
        EEG.saved = 'no';
        EEG.etc = struct;
        EEG.notch = [];
        
    elseif strcmpi(varargin{1}, 'update')
        for jj = 1:length([EEG.event.latency])
            EEG.event(jj).resp = 0;
        end
        EEG.urevent = EEG.event;
        EEG.eventcode = '';
        EEG.analysis = EEG.event;
        EEG.notch = [];
        EEG.reject.excess = [];
        EEG.datreject = struct;
        
        
    elseif ~mod(nargin, 2) && nargin > 0
        e = sprintf('Unbalanced set of identifiers and variables.\nMake sure each variable argument is preceded with an identifier.');
        error(e);
        
    else
        ident = varargin(1:2:nargin-1);
        if sum(cellfun(@(x) contains(string(lower(x)), "event"), ident))
            EEG.analysis = struct;
            EEG.event = struct;
            EEG.urevent = EEG.event;
        end
        
        if sum(cellfun(@(x) contains(string(lower(x)), "labels"), ident))
            EEG.chanlocs = struct;
        end
        
        for ii = 1:2:nargin-1
            if strcmpi(varargin{ii}, 'name')
                name = varargin{ii+1};
                EEG.setname = name;
            end
            
            if strcmpi(varargin{ii}, 'reference')
                EEG.ref = varargin{ii+1};
            end
            
            if strcmpi(varargin{ii}, 'dat')
                dat = varargin{ii+1};
                EEG.data = dat;
                EEG.nbchan = size(dat,1);
                EEG.pnts = size(dat,2);
                if ~isnan(EEG.srate)
                    EEG.xmin = 0;
                    EEG.xmax = size(dat,2)/EEG.srate;
                end
                EEG.times = 0:size(dat,2)-1;
            end

            if strcmpi(varargin{ii}, 'labels')
                lab = varargin{ii+1};
                for jj = 1:length(lab)
                   EEG.chanlocs(jj).labels = char(lab(jj));
                end
            end

            if strcmpi(varargin{ii}, 'srate')
                srate = varargin{ii+1};
                EEG.srate = srate;
            end

            if strcmpi(varargin{ii}, 'eventcode')
                EEG.eventcode = varargin{ii+1};
            end
            
            if strcmpi(varargin{ii}, 'eventindex')
                evn_idc = varargin{ii+1};
                for jj = 1:length(evn_idc)
                    EEG.event(jj).latency = evn_idc(jj);
                end
                EEG.urevent = EEG.event;
            end

            if strcmpi(varargin{ii}, 'eventtype')
                evns = varargin{ii+1};
                for jj = 1:length(evns)
                   EEG.event(jj).duration = 1;
                   EEG.event(jj).channel = 0;
                   EEG.event(jj).bytime = [];
                   EEG.event(jj).bvmknum = jj;
                   if ~isempty(evns{jj})
                       EEG.event(jj).type = evns{jj};
                       EEG.event(jj).code = 'Stimulus';
                       EEG.event(jj).urevent = jj;
                   end
                end
                EEG.urevent = EEG.event;
            end

            if strcmpi(varargin{ii}, 'responsetime')
                resp_tm = varargin{ii+1};
                for jj = 1:length(resp_tm)
                    EEG.event(jj).resp = resp_tm(jj);
                end
                EEG.urevent = EEG.event;
            end
            
            if strcmpi(varargin{ii}, 'eventreject')
                evn_rej = varargin{ii+1};
                for jj = 1:length(evn_rej)
                   if ~isempty(evn_rej{jj})
                       EEG.event(jj).reject = evn_rej{jj};
                   end
                end
                EEG.urevent = EEG.event;
            end
            
            if strcmpi(varargin{ii}, 'analysiseventidx')
                evn_idc = varargin{ii+1};
                for jj = 1:length(evn_idc)
                    EEG.analysis(jj).latency = evn_idc(jj);
                end
            end

            if strcmpi(varargin{ii}, 'analysiseventtype')
                evns = varargin{ii+1};
                for jj = 1:length(evns)
                   if ~isempty(evns{jj})
                       EEG.analysis(jj).type = evns{jj};
                   end
                end
            end

            if strcmpi(varargin{ii}, 'analysisresponsetime')
                resp_tm = varargin{ii+1};
                if iscell(resp_tm)
                    resp_tm = cellfun(@(x) str2double(x), resp_tm);
                end
                for jj = 1:length(evn_idc)
                    EEG.analysis(jj).resp = resp_tm(jj);
                end
            end
            
            if strcmpi(varargin{ii}, 'excesschans')
               echans = varargin{ii+1};
               for jj = 1:length(echans)
                  EEG.reject(jj).excess = char(echans(jj));
               end
            end
            
            if strcmpi(varargin{ii}, 'excesschansdata')
                if ~isempty(varargin{ii+1})
                    EEG.datreject.excess = varargin{ii+1};
                end
            end
            
            if strcmpi(varargin{ii}, 'rejectchans')
               rchans = varargin{ii+1};
               if isfield(EEG.reject, 'rej')
                    EEG.reject = rmfield(EEG.reject, 'rej');
               end
               if ~isempty(rchans)
                   for jj = 1:length(rchans)
                      EEG.reject(jj).rej = char(rchans(jj));
                   end
               else
                   for jj = 1:length({EEG.reject.excess})
                      EEG.reject(jj).rej = '';
                   end
               end
            end
            
            if strcmpi(varargin{ii}, 'rejectchansdata')
                EEG.datreject.reject = varargin{ii+1};
            end
            
            if strcmpi(varargin{ii}, 'notchfilter')
                flt = varargin{ii+1};
                if flt == -1
                    EEG.notch = [];
                else
                    EEG.notch = flt;     
                end
            end
            
            if strcmpi(varargin{ii}, 'saved')
                EEG.saved = varargin{ii+1};
            end
        end

    end

end

























