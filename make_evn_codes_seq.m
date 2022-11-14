function [evnout, rtm, evn_code] = make_evn_codes(cv, evnin, seq)
    
    header = cv.Properties.VariableNames;
    idents = prompt('choose identifiers', header);
    evn_code = strjoin(idents,'-');
    
    
    evn = cell(size(cv,1), 1);
    
    if nargin > 1
        evnin = cellfun(@(x) [x '-'], evnin, 'uni', 0);
        emsk = ~cellfun(@(x) contains(x,'boundary'), evnin);
        olevn = evnin(emsk);
        seq_msk = zeros(size(cv,1), length(seq));
        for k = 1:length(seq)
            seq_msk(:,k) = cellfun(@(x) strcmp(x, seq{k}), cv.Liste);
        end
        cv(~sum(seq_msk, 2), :) = [];
    else
        evnin = evn;
        olevn = evn;
        emsk = ones(length(evn), 1);
    end
    
    
    
    for ii = 1:size(cv,1)
        evn_nm = '';
        for jj = 1:length(idents)

            if ~iscell(cv.(idents{jj}))
                evn_nm = [evn_nm num2str(cv.(idents{jj})(ii))];
            else
                evn_nm = [evn_nm cv.(idents{jj}){ii}];
            end

            if jj ~= length(idents)
                evn_nm = [evn_nm '-'];
            end

        end

        evn{ii} = [olevn{ii} evn_nm];

    end
    
    if all(emsk)
        evnout = evn;
    else
        evnout = evnin;
        evnout(emsk) = evn;
    end
    
    if any(cellfun(@(x) strcmp(x,'Rtok'), header))
        if iscell(cv.Rtok) 
            rtm = cellfun(@(x) str2double(x), cv.Rtok);
        else
            rtm = cv.Rtok;
        end
    elseif any(cellfun(@(x) strcmp(x,'TR'), header))
        rtm = nan(length(evnin),1);
        if iscell(cv.TR) 
            rtm_temp = cellfun(@(x) str2double(x), cv.TR);
        else
            rtm_temp = cv.TR;
        end
        rtm(emsk) = rtm_temp;
    end
end