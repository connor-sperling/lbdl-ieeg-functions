function plot_connectivity_map(A, subj, ref, lock, band, pth, loc, ztol, varargin)

    for v = 1:2:length(varargin)-1
        if strcmp(varargin{v},'ar')
            ar_ord = varargin{v+1};
        elseif strcmp(varargin{v},'sparsity')
            sparsity = varargin{v+1};
        elseif strcmp(varargin{v},'event')
            evn_nm = varargin{v+1};
        elseif strcmp(varargin{v},'maptype')
            mtype = varargin{v+1};
        elseif strcmp(varargin{v},'barlab')
            barlab = varargin{v+1};
        elseif strcmp(varargin{v},'id')
            id = varargin{v+1};
        elseif strcmp(varargin{v},'NV')
            params = varargin{v+1};
            alpha = params(1);
            dthresh = params(2);
        elseif strcmp(varargin{v},'color')
            c = varargin{v+1};
        end
    end
  
    T = get_lock_times(lock);
    N = size(A,1);
    vis = 'off';
    h = figure('visible',vis);

    imagesc(A);
%     if exist('alpha', 'var') % For network verification map
%         title({sprintf('%s %s %s',subj,T.lock_abv,band);sprintf('Significant %s  ( \\alpha = %.2f )', mtype, alpha)}, 'FontSize',24)
%     elseif exist('mtype', 'var') % For mean adjacenecy matrix
%         title({sprintf('%s %s %s',subj,T.lock_abv,band); mtype},'FontSize',24) 
%     elseif exist('evn_nm', 'var') && exist('sparsity','var') % for independent trials (undirected)
%         title(sprintf('%s | %s = %0.1f%% | q = %d', evn_nm, 'Sparsity', sparsity*100, ar_ord))
%     elseif exist('evn_nm', 'var') % for independent trials (directed)
%         title(sprintf('%s %s %s %s', subj, T.lock_abv, band, evn_nm))
%     end

    set(gca, 'XTick', 1:N, 'YTick', 1:N)
    set(h, 'Units','pixels','Position',[1450 425 1100 900])
    if ~isempty(loc)
        loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
        if isempty(loc_subj)
            return
        end
        regions = loc_subj.region;
        rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
        lat = cellfun(@(x) x{1}, rsplt, 'uni', 0);
        hemi_div = find(cellfun(@(x) strcmp(x,'R'),lat)==1, 1)-.5;
        if isempty(hemi_div)
            hemi_div = N+.5;
        end
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
        e = 0.005;
        ym = 0.0509+.03; yb = 0.6567;
        xm = -0.0598-.03; xb = 0.4421;
        x_cushion = 0.107;
        y_cushion = .085;
        
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
            text(xm*N+xb, mean([k sz_reg+1+k]), Ru(j), 'HorizontalAlignment','center','FontWeight','bold','FontSize',24) % y-axis text
            tx = text(mean([k sz_reg+1+k]), ym*N+yb+N, Ru(j),'HorizontalAlignment','center','FontWeight','bold','FontSize',24); % x-axis text
            set(tx,'Rotation',50);
            x_pos = x_pos+sz_reg*dx;
            y_pos = y_pos-sz_reg*dy;
            k = k + sz_reg;
        end
    end
    
    
    original_size = get(gca, 'Position');
    if exist('alpha', 'var')
        av = A(:);
        cmin = ceil(min(av(av<0)));
        cmax = floor(max(av(av>0)));
        % has to be an if-elseif statement, controlling for possibility of emtpy cmax or cmin
        if cmax == dthresh 
            dthresh = dthresh/2;
        elseif abs(cmin) == dthresh
            dthresh = dthresh/2;
        end
        if isempty(cmax)
            rlen=0;
            blen = round((abs(min(av))-dthresh)*10);
            nz = dthresh*10;
        elseif isempty(cmin)
            rlen=round((max(av)-dthresh)*10);
            blen = 0;
            nz = dthresh*10;
        else
            rlen = round((max(av)-dthresh)*10);
            blen = round((abs(min(av))-dthresh)*10);
            nz = 2*dthresh*10;
        end
        L = rlen+blen+nz;
        if islogical(A)
            colormap gray;
        else
            c1 = [linspace(c(1,1,1),c(1,2,1),rlen);linspace(c(2,1,1),c(2,2,1),rlen);linspace(c(3,1,1),c(3,2,1),rlen)]';
            c2 = [linspace(c(1,1,2),c(1,2,2),blen);linspace(c(2,1,2),c(2,2,2),blen);linspace(c(3,1,2),c(3,2,2),blen)]';
            cmap = zeros(L,3);
            cmap(1:blen,:) = c2;
            cmap(blen+nz+1:end,:) = c1;
            cmap(blen+1:blen+nz,:) = .5*ones(nz,3);
            colormap(cmap)
            cb = colorbar('Ticks',[cmin,(-dthresh+cmin)/2,-dthresh,0,dthresh,(dthresh+cmax)/2,cmax]);
            cb.Label.String = barlab;
            cb.Label.FontSize = 18;
            cb.FontSize = 18;
            set(gca, 'Position', original_size);
        end
        
    else
        cb = colorbar;
        if exist('barlab', 'var')
            cb.Label.String = barlab;
        end
        
        cb.Label.FontSize = 18;
        cb.FontSize = 18;
        
        set(gca, 'Position', original_size);
    end
    
    
    
    % Save connectivity map as png and fig
    
    if exist('evn_nm', 'var')
        sname = sprintf('%s/%s_%s_%s_%s_%s', pth, subj, ref, lock, band, evn_nm);
    else
        sname = sprintf('%s/%s_%s_%s_%s_%s', pth, subj, ref, lock, band, id);
    end
    saveas(gca, sprintf('%s_map.png',sname))
    close

    % Make and save weights histogram
%     if ~exist('alpha', 'var')
%         figure('visible',vis)
%         Anz = A(:);
%         Anz = Anz(Anz > ztol);
%         histogram(Anz)
%         if exist('condition', 'var') % For mean adjacenecy matrix
%             title(sprintf('%s %s %s %s', condition, subj, lock, band))
%         elseif exist('evn_nm', 'var') && exist('sparsity','var') % for independent trials (undirected)
%             title(sprintf('%s | %s = %0.1f%% | q = %d',evn_nm,'Sparsity',sparsity*100,ar_ord))
%         elseif exist('evn_nm', 'var') % for independent trials (directed)
%             title(sprintf('%s %s %s %s', subj, T.lock_abv, band, evn_nm))
%         end
%         saveas(gca, sprintf('%s_hist.png', sname));    
%         close
%     end
    
end