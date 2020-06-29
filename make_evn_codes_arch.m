function [evn, rtm, evn_code] = make_evn_codes_arch(cv)
    
    header = cv.Properties.VariableNames;
    idents = prompt('choose identifiers', header);
    evn_code = strjoin(idents,'-');
    
    evn = cell(size(cv,1), 1);
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
        
        evn{ii} = evn_nm;
        
    end
    
    if iscell(cv.Rtok)
        rtm = cellfun(@(x) str2double(x), cv.Rtok);
    else
        rtm = cv.Rtok;
    end

end