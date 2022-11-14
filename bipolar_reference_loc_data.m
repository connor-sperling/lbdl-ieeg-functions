function xl_bip_nm = bipolar_reference_loc_data(fdir, fname, atlas)


data = readtable(sprintf('%s/%s.xlsx', fdir, fname));
subjs = data.subj;
[~,~,subIdx] = unique(subjs,'stable');


locbi = cell2table(cell(0,4), 'VariableNames', {'subj', 'Lateralization', 'SEEGChannel', 'Localization'});

    
for j = 1:max(subIdx)

    subMsk = subIdx == j;
    subdat = data(subMsk,:);

    subj = subdat.subj;
    loc = subdat.(atlas);
    lab = subdat.SEEGChannel;
    if any(strcmp('Lateralization',subdat.Properties.VariableNames))
        lat = subdat.Lateralization;
    else
        lat = zeros(length(loc), 1);
    end
    
    
    
    alph = cellfun(@(x) x(isstrprop(x,'alpha')),lab,'uni',0);
    numr = cellfun(@(x) str2double(x(isstrprop(x,'digit'))),lab,'uni',0);

    [~,~,shftIdx] = unique(alph,'stable');
    [shftIdx, i] = sort(shftIdx);
    loc = loc(i);
    alph = alph(i);
    numr = numr(i);

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

    dIdx = find(diff(shftIdx));

    dlab = alph;
    dlab(dIdx) = [];
    dlab(end) = [];
    dnumr = numr;
    dnumr(dIdx+1) = [];
    dnumr(1) = [];
    dlab = cellfun(@(x,y) sprintf('%s%.2i-%.2i',x,y,y-1),dlab,dnumr,'uni',0);
    dlab(~cmsk) = [];
    
    loc_p = loc(2:end);
    loc_m = loc(1:end-1);
    dloc = cellfun(@(x,y) sprintf('%s/%s',x,y), loc_p, loc_m,'uni',0);
    dloc(dIdx) = [];
    dloc(~cmsk) = [];
    
    lat(1) = [];
    lat(dIdx) = [];
    lat(~cmsk) = [];
    
    subj = subj(1:length(dlab));
    SEEGChannel = dlab;
    Localization = dloc;
    Lateralization = lat;
    dsubloc = table(subj, Lateralization, SEEGChannel, Localization);
    locbi = [locbi; dsubloc];
end
xl_bip_nm = sprintf('%s_%s_bipolar',fname,atlas);
writetable(locbi, sprintf('%s/%s.xlsx',fdir,xl_bip_nm));
end
