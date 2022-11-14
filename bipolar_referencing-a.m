function [ddat, dlab] = bipolar_referencing (dat, lab)


    alph = cellfun(@(x) x(isstrprop(x,'alpha')),lab,'uni',0);
    numr = cellfun(@(x) str2double(x(isstrprop(x,'digit'))),lab,'uni',0);
    
    seegMsk = false(size(lab));
    chkMsk = zeros(size(lab));
    

    for ii = 1:length(numr)
        if numr{ii} > 10
            snum = num2str(numr{ii});
            if str2double(snum(2:end)) <= 10
                alph{ii} = [alph{ii} snum(1)];
                numr{ii} = str2double(snum(2:end));
            end
        end
    end

    [~,~,shftIdx] = unique(alph,'stable');

    for sI = 1:max(shftIdx)
      sMsk = shftIdx == sI;
      if sum(sMsk)>=2 && all(diff([numr{sMsk}]) == 1) && all(diff(find(sMsk == true)) == 1)
        % assumes each shaft >=2 contacts and that the contact #'s count up by 1's
        % assumes contact numbers are always ascending
        seegMsk(sMsk) = true;
        chkMsk(sMsk) = sI;
      end
    end
  
    
    alph = alph(seegMsk);
    numr = numr(seegMsk);
    [shftLabs,~,shftIdx] = unique(alph,'stable');

    dat = [chkMsk(seegMsk)' dat(seegMsk,:)];
    %dat = [shftIdx rand(5,length(shftIdx))'];

    ddat = diff(dat,1,1); % 2-1, 3-2
    dIdx = find(diff(shftIdx));
    ddat(dIdx,:) = []; %remove intershaft derived channels

    % get bipolar labels
    dlab = alph;
    dlab(dIdx) = [];
    dlab(end) = [];
    dnumr = numr;
    dnumr(dIdx+1) = [];
    dnumr(1) = [];
    dlab = cellfun(@(x,y) sprintf('%s%.2i-%.2i',x,y,y-1),dlab,dnumr,'uni',0);

end

















