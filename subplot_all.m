function subplot_all(handles, axes, P, save_dir)

    m = length(handles);
    Q = P + 1;
    rv = mod(m,P);
    rh = mod(m,Q);
    
    h = 1;
    for p = 1:P
        N = floor(m/P);
        if p <= rv
            N = N + 1;
        end

        for ii = 1:N
            figure(p+length(handles));
            si = subplot(N,1,ii);
            copyobj(handles{h}, si);
            set(gca, 'Title', get(axes{h}, 'Title'));

            h = h + 1;
        end
        figure(p+length(handles));
        set(gcf, 'Units','pixels','Position',[-1070 -300 1060 1750])
        
        saveas(gca, sprintf('%sall channels %d vert.jpeg',save_dir, p))
        close gcf
    end
    
    h = 1;
    for p = 1:Q
        N = floor(m/Q);
        if p <= rh
            N = N + 1;
        end

        for ii = 1:N
            figure(p+length(handles));
            si = subplot(N,1,ii);
            copyobj(handles{h}, si);
            set(gca, 'Title', get(axes{h}, 'Title'));
            figure(h);
            close gcf
            h = h + 1;
        end
        figure(p+length(handles));
        set(gcf, 'Units','pixels','Position',[0 0 1916 950])

        saveas(gca, sprintf('%sall channels %d horz.jpeg',save_dir, p))
        close gcf
    end
    
end


