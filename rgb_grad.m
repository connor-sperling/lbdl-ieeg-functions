function [r, g, b] = rgb_grad(r, g, b, rinit, ginit, binit, size)
  
    rr = floor((255-rinit)/size)/255;
    gr = .75*floor((255-ginit)/size)/255;
    br = .4*floor((255-binit)/size)/255;

%     if r == 1 && g == 1
%         binit = binit + 30;
%         br = binit;
%     else
%         br = 0;
%     end
    
    if (r + rr) <= 1 && (r + rr) >= 0
        r = (r + rr);
    else
        r = 1;
    end

    if (g + gr) <= 1 && (g + gr) >= 0
        g = (g + gr);
    else
        g = 1;
    end

    if (b + br) <= 1 && (b + br) >= 0
        b = (b + br);
    else
        b = 1;
    end

end