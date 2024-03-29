function write_significant_localization_table(subjs_dir, xl_nm, atlas, study, ref, locks, bands)

xl_dir = sprintf('%s/Excel Files',subjs_dir);

loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end
key = readtable(loc_key_file);
subjs = unique(loc.subj, 'stable');

for b = 1:length(bands)
    band = bands{b};
for l = 1:length(locks)
    lock = locks{l};
    sig_loc = cell2table(cell(0,4), 'variableNames', loc.Properties.VariableNames);
    loc_org = cell(0, 3);
    all_region_code = cell(0,1);
    for s = 1:length(subjs)
        % filter other subjects from table
        subj = subjs{s};
        loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
        
        subj_loc_org = cell(0,4);
        
        % get significant channels
        lock_pth = sprintf('%s/%s/analysis/%s/%s/%s', subjs_dir, subj, study, ref, lock);
        tvdf = sprintf('%s/ALL/TvD/%s/ALL_%s_TvD.mat', lock_pth, band, band);
        load(tvdf, 'TvD')
        lab = TvD(:,2);
        
        % Patch for sd14. The RHB shaft was not localized by Burke but it
        % shows up in the data and it is found significant. The code below
        % removes it but this is a temporary fix as it should be included
        % once it is localized.
        if strcmp(subj, 'sd14') 
            lab(cellfun(@(x) contains(x, 'RHB'), lab)) = [];
        end
        
        % filter out insignificant channels
        if length(lab) ~= sum(ismember(loc_subj.SEEGChannel, lab))
            d=1;
        end
        sig_loc_subj = loc_subj(ismember(loc_subj.SEEGChannel, lab),:);
        sig_loc = [sig_loc; sig_loc_subj]; % store list
        
        % organize table by unique localization names
        uniq_loc = unique(sig_loc_subj.Localization);
        for n = 1:length(uniq_loc)
            loc_nm = uniq_loc{n};
            loc_msk = cellfun(@(x) strcmpi(x, loc_nm), sig_loc_subj.Localization);
            all_loc_n = table2cell(sig_loc_subj(loc_msk,:));
            if isempty(all_loc_n)
                dummy = 1;
            end
            subj_loc_org = [subj_loc_org; all_loc_n];
        end
        
        % organize table in alphabetical order of channels
        [~, ord] = sort(subj_loc_org(:,3));
        subj_loc_org = subj_loc_org(ord, :);
        

        % make region code column
        if contains(xl_dir, 'San_Diego')
            region_code = cell(size(subj_loc_org,1),1);
            for k = 1:size(subj_loc_org,1)
                kloc = strsplit(subj_loc_org{k,4},'/');
                kloc_d = kloc{1};
                kloc_m = kloc{2};
                region_code_d = char(key.abv(cellfun(@(x) contains(kloc_d,x), key.region)));
                region_code_m = char(key.abv(cellfun(@(x) contains(kloc_m,x), key.region)));
                if contains(kloc_d, 'lh') || contains(kloc_d, 'Left') || contains(kloc_d, 'L-')
                    dhemi = 'L';
                elseif contains(kloc_d, 'rh') || contains(kloc_d, 'Right') || contains(kloc_d, 'R-')
                    dhemi = 'R';
                else
                    tlab = subj_loc_org{k,3};
                    dhemi = tlab(1);
                end

                if contains(kloc_m, 'lh') || contains(kloc_m, 'Left') || contains(kloc_d, 'L-')
                    mhemi = 'L';
                elseif contains(kloc_m, 'rh') || contains(kloc_m, 'Right') || contains(kloc_d, 'R-')
                    mhemi = 'R';
                else
                    tlab = subj_loc_org{k,3};
                    mhemi = tlab(1);
                end

                % sanity check that dhemi = mhemi
                if strcmp(dhemi, mhemi) 
                    hemi = dhemi;
                % dhemi ~= mhemi only when one region is unknown. the unknown is still in the same hemi though
                else 
                    hemi = erase([dhemi mhemi], 'U');
                end
                region_code(k) = {sprintf('%s-%s/%s',hemi,region_code_d,region_code_m)};
            end
        else
            region_code = cellfun(@(x,y) sprintf('%s-%s',x,y),subj_loc_org(:,2),subj_loc_org(:,4), 'uni', 0);
        end
        
        subj_loc_org = [subj_loc_org region_code];
        
        loc_lab = subj_loc_org(:,2);
        rcsplt = cellfun(@(x) strsplit(x,'-'), region_code, 'uni', 0);
        H = cellfun(@(x) x(1), rcsplt);
        bip_region = cellfun(@(x) x(2), rcsplt);
        [~,~,hidx] = unique(H,'stable');
        didx = []; midx = [];
        R = cell(length(loc_lab),1);
        for h = 1:max(hidx)
            hmsk = hidx == h;
            single_hemi = unique(H(hmsk));
            if length(single_hemi) > 1
                error('more than one hemisphere')
            end
            subj_hem_reg = region_code(hmsk);
            subj_hem_bip_reg = bip_region(hmsk);
            loc_lab_hem = loc_lab(hmsk);
            contacts = subj_loc_org(hmsk,3);
            Dreg = {};
            Mreg = {};
            ord_position = zeros(sum(hmsk),1);
            for m = 1:sum(hmsk)
                regsplt = strsplit(subj_hem_bip_reg{m},'/');
                dreg = regsplt{1}; mreg = regsplt{2};
                Dreg = [Dreg; {dreg}];
                Mreg = [Mreg; {mreg}];
                didx = find(cellfun(@(x) strcmp(x,dreg), key.abv)==1, 1);
                if length(didx) == 0
                    stop = 1;
                end
                midx = find(cellfun(@(x) strcmp(x,mreg), key.abv)==1, 1);
                try
                    if contains(mreg, 'WM') && ~contains(dreg, 'WM') || strcmp(mreg, 'U') && ~strcmp(dreg, 'U') || contains(mreg, 'blanc') && ~contains(dreg, 'blanc') || contains(mreg, 'out') && ~contains(dreg, 'out')
                        ord_position(m) = didx;
                        R((h-1)*sum(hidx == h-1)+m) = {[char(single_hemi) '-' dreg]};
                    elseif isempty(mreg) && ~isempty(dreg)
                        ord_position(m) = didx;
                        R((h-1)*sum(hidx == h-1)+m) = {[char(single_hemi) '-' dreg]};
                    else
                        ord_position(m) = midx;
                        R((h-1)*sum(hidx == h-1)+m) = {[char(single_hemi) '-' mreg]};
                    end
                catch
                    error('Failed on %s, %s, %s', subj, subj_hem_bip_reg{m}, contacts{m});
                end

                % if distal region matches with previous defined region.
                % Depends on electrodes of the same shaft being ordered d -> m
                if m > 1
                    if strcmp(dreg, R(end-1))
                        ord_position(m) = didx;
                    end
                end
            end
            [~, ord_idx] = sort(ord_position);
            subj_loc_org_hemi = subj_loc_org(hmsk,:);
            subj_loc_org(hmsk,:) = subj_loc_org_hemi(ord_idx,:);
            R_hemi = R(hmsk);
            R(hmsk) = R_hemi(ord_idx);
        end
        
        subj_loc_org = [subj_loc_org R];
        
        % if reverse ordering needs to be done
%         loc_lab = subj_loc_org(:,2);
%         % organize table by shaft contacts ordered distal to medial
%         [~,~,shftidx] = unique(cellfun(@(x) x(isstrprop(x,'alpha')),loc_lab,'uni',0), 'stable');
%         loc_lab_ord = cell(length(loc_lab), 1);
%         for i = 1:max(shftidx)
%             smsk = shftidx == i;
%             loc_lab_ord(smsk) = flipud(loc_lab(smsk));
%         end
%         [~,ord] = ismember(loc_lab, loc_lab_ord);
%         subj_loc_org = subj_loc_org(ord, :);
        
        loc_org = [loc_org; subj_loc_org]; % store list
    end
    loc_org = cell2table(loc_org(:,3:end)); % drop the subj/lat cols. Useful for debugging in loops, not necessary for table
    loc_org.Properties.VariableNames = {'channel_organized', 'localization_organized', 'loc_code', 'region'};
    sig_loc = [sig_loc loc_org];

    writetable(sig_loc, sprintf('%s/significant_%s_%s_%s_%s_%s_localization.xlsx',xl_dir,study,ref,lock,band,atlas))
end
end
end
