function [evn, rtm, evn_code] = make_evn_codes(cv, msk)
    
    if nargin < 2
        msk = false(size(cv,1),1);
    end
    
    header = cv.Properties.VariableNames;
    idents = prompt('choose identifiers', header);
    evn_code = strjoin(idents,'-');
    
    evn = cell(size(msk,1), 1);
    
    k = 1;
    for ii = 1:size(msk,1)
        if msk(ii)
            evn{ii} = 'reject';
        else
            evn_nm = '';
            for jj = 1:length(idents)

                if ~iscell(cv.(idents{jj}))
                    evn_nm = [evn_nm num2str(cv.(idents{jj})(k))];
                else
                    evn_nm = [evn_nm cv.(idents{jj}){k}];
                end

                if jj ~= length(idents)
                    evn_nm = [evn_nm '-'];
                end

            end

            evn{ii} = evn_nm;
            k = k + 1;
        end

    end
    
    evn(cellfun(@(x) isempty(x), evn)) = {'reject'};
    
     if any(cellfun(@(x) strcmp(x,'Rtok'), header))
        if iscell(cv.Rtok) 
            rtm = cellfun(@(x) str2double(x), cv.Rtok);
        else
            rtm = cv.Rtok;
        end
     elseif any(cellfun(@(x) strcmp(x,'TR'), header))
        rtm = nan(size(msk));
        if iscell(cv.TR) 
            temp = cellfun(@(x) str2double(x), cv.TR);
        else
            temp = cv.TR;
        end
        rtm(~msk) = temp;
     end
end