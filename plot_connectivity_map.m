function plot_connectivity_map(A, ba, ar_ord, subj, evn_nm, ref, lock, band, pth, loc)

    evn_nm = erase(evn_nm,'.mat');
    N = size(A,1);
    vis = 'on';
    h = figure('visible',vis);

    imagesc(A);
    title(sprintf('%s | %s = %d | q = %d', evn_nm, '\alpha/\beta', ba, ar_ord))
    set(gca, 'XTick', 1:N, 'YTick', 1:N)
    set(h, 'Units','pixels','Position',[1450 425 1100 900])
    if ~isempty(loc)
        loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
        regions = loc_subj.region;
        rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
        lat = cellfun(@(x) x{1}, rsplt, 'uni', 0);
        hemi_div = find(cellfun(@(x) strcmp(x,'R'),lat)==1, 1)-.5;
        line([.5, N+.5], [hemi_div hemi_div], 'color', 'r', 'linewidth', 2);
        line([hemi_div hemi_div], [.5, N+.5], 'color', 'r', 'linewidth', 2);
        [Ru,~,Ridx] = unique(regions,'stable');
        P = h.CurrentAxes.Position;
        xst = P(1); xen = xst + P(3);
        yst = P(2); yen = yst + P(4);
        dx = (xen-xst)/N;
        dy = (yen-yst)/N;
        x_pos = xst;
        y_pos = yen;
        x_cushion = xst - dx;
        y_cushion = yst - dy;
        e = 0.005;
        k = 0;
        for j = 1:max(Ridx)
            sz_reg = sum(Ridx == j);
            xline = [x_pos+e x_pos+sz_reg*dx-e];
            yline = [y_pos-e y_pos-sz_reg*dy+e];
            annotation('line', xline, [y_cushion y_cushion], 'linewidth', 2, 'color', 'k') % x-axis line
            annotation('line', [xline(1) xline(1)], [y_cushion y_cushion+.005], 'linewidth', 2, 'color', 'k')
            annotation('line', [xline(2) xline(2)], [y_cushion y_cushion+.005], 'linewidth', 2, 'color', 'k')
            annotation('line', [x_cushion x_cushion], yline, 'linewidth', 2, 'color', 'k') % y-axis line
            annotation('line', [x_cushion x_cushion+.005], [yline(1) yline(1)],'linewidth', 2, 'color', 'k')
            annotation('line', [x_cushion x_cushion+.005], [yline(2) yline(2)], 'linewidth', 2, 'color', 'k') 
            text(-1.8, mean([k sz_reg+1+k]), Ru(j), 'HorizontalAlignment','center','FontWeight','bold') % y-axis text
            tx = text(mean([k sz_reg+1+k]), N+2.7, Ru(j),'HorizontalAlignment','center','FontWeight','bold'); % x-axis text
            set(tx,'Rotation',50);
            x_pos = x_pos+sz_reg*dx;
            y_pos = y_pos-sz_reg*dy;
            k = k + sz_reg;
        end
    end
    
    
    saveas(gca, sprintf('%s/%s_%s_%s_%s_%s_map.png', pth, subj, ref, lock, band, evn_nm));

    figure('visible',vis)
    histogram(A(:), 30)
    title(sprintf('%s | %s = %d | q = %d',evn_nm,'\alpha/\beta',ba,ar_ord))
    saveas(gca, sprintf('%s/%s_%s_%s_%s_%s_hist.png', pth, subj, ref, lock, band, evn_nm));
    
end