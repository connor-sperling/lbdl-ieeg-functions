function zt = z_thresh(z, p, a)
    if isnan(z) || p > a
        zt = 0;
    else
        zt = z;
    end
%     if saturate
%         if z > 0
%             zt = 1;
%         elseif z < 0
%             zt = -1;
%         end
%     end
end