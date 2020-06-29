function [ddat, dlab] = bipolar_referencing_new(dat,lab)

    alph = cellfun(@(x) x(isstrprop(x,'alpha')),lab,'uni',0);
    numr = cellfun(@(x) str2double(x(isstrprop(x,'digit'))),lab,'uni',0);
    
    [~,~,shftIdx] = unique(alph,'stable');
    [shftIdx, i] = sort(shftIdx);
    alph = alph(i);
    numr = numr(i);
    dat = dat(i,:);
    
    cmsk = [];
    for sI = 1:max(shftIdx)
        sMsk = shftIdx == sI;
        salph = alph(sMsk);
        snumr = numr(sMsk);
        if all(cellfun(@(x) x>10, snumr))
            for ii = 1:length(snumr)
                strnum = num2str(snumr{ii});
                if str2double(strnum(2:end)) < 10 || str2double(strnum) > 100
                    salph{ii} = [salph{ii} strnum(1)];
                    snumr{ii} = str2double(strnum(2:end));
                end
            end
            alph(sMsk) = salph;
            numr(sMsk) = snumr;
        end
        cmsk = [cmsk diff([numr{sMsk}]) == 1];
    end
    
    
    ddat = diff(dat,1,1); % 2-1, 3-2
    dIdx = find(diff(shftIdx));
    ddat(dIdx,:) = []; %remove intershaft derived channels
    ddat(~cmsk,:) = [];

    % get bipolar labels
    dlab = alph;
    dlab(dIdx) = [];
    dlab(end) = [];
    dnumr = numr;
    dnumr(dIdx+1) = [];
    dnumr(1) = [];
    dlab = cellfun(@(x,y) sprintf('%s%.2i-%.2i',x,y,y-1),dlab,dnumr,'uni',0);
    dlab(~cmsk) = [];
end






