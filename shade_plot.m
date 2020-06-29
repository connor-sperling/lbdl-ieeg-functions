function y_points = shade_plot(x_points,y,dy,facecolor,transparency,plot_y)
%
%   shade_plot(x_points,y,dy,color,transparency)
%
%       plots a shaded area beteween y_low and y_high across x_points
%       using the color and transparency values (default 'b', 0.8)
%
%
    if ~exist('facecolor'), facecolor = 'b'; end
    if ~exist('transparency'), transparency = 0.6; end
    if ~exist('plot_y'), plot_y = 0; end
    
    if plot_y
        h=plot(x_points, y,'color', rgb('darkslategray'),'LineWidth',2,'linesmoothing','on'); hold on;
    end
    x_points = [x_points fliplr(x_points)];
    y_points = [y+dy fliplr(y-dy)];
    %y_points = [y-dy y+dy];
    h=fill(x_points,y_points,facecolor);
    set(h,'EdgeColor',facecolor,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color
    %if plot_y
    %    hold off;
    %end

end
