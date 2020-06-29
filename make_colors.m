function c = make_colors (c, varargin)

% if c is a pre-defined color matrix:
%
%     make_colors(c) plots your colors
%
%     c  :  Nx3 or 3xN matirx (N = number of colors)
%     
% if you want to define a color matrix based on rgb functions:
%
%     c = make_colors(c, f1, f2, f3, 'plot')
%
%     c  :  number of colors you want
%     fk :  function handle (i.e. @(x) 3*x + 1. Note fk must be positive in [1, number colors])
%     (remove 'plot' argument to just return color matrix without plotting)
%     
if nargin == 0
    disp('Example:')
    disp('make_colors(5, "plot", @(x) 3*x+.5, @(x) 10*x+1, @(x) 3*x+4)')
    c = make_colors(5, @(x) 3*x+.5, @(x) 10*x+1, @(x) 3*x+4, 'plot');
    return
end
 
if nargin > 1
    plt = 0;
    fidx = [];
    for ii = 1:nargin-1
        if strcmpi(varargin{ii},'plot')
            plt = 1;
            pidx = ii;
        end
        if isa(varargin{ii},'function_handle')
            fidx = [fidx ii];
        end
    end
    if length(fidx) ~= 3
        error('PLease choose 3 functions. Define a function for each rgb value')
    end
    numc = c;
    xc = 1:numc;
    c = zeros(3,numc);
    k = 1;
    for ii = fidx
        f = varargin{ii};
        c(k,:) = f(xc);
        k = k+1;
    end
    c = floor(c.*(255/max(max(c))));
else
    plt = 1;
end

if plt
    szc = size(c);

    if szc(1) < szc(2)
        c = c';
    elseif szc(1) == szc(2)
        warning('testcolorgrad assumes different color values in rows and rgb values in columns')
    end

    numc = size(c,1);
    x = linspace(0,2*pi,1e3);
    Y = zeros(numc,length(x));

    for ii = 1:numc
        Y(ii,:) = cos(x-(ii-1)/4);
    end

    mc = max(max(c));

    if mc > 1
        rgbc = c;
        c = c./255;
    else
        rgbc = c*255;
    end

    rgb = {'r', 'g', 'b'};
    close all
    figure
    hold on
    for ii = 1:3
        scatter(1:numc, rgbc(:,ii), rgb{ii})
    end
    hold off

    figure
    hold on
    for ii = 1:numc
        plot(x,Y(ii,:),'color',c(ii,:),'linewidth',2)
    end
end




end