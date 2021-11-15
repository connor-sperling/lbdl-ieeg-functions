function [stp, tol] = init_stepsize(dat, ba, ar_ord, ztol, S)

    % parameters
    opt_sparsity = 0.6;
    tol = 0.01;
    tol_stp = 0.01;
    stp = 1000;

    sparsity = 0;
    
    N = size(dat,1);
    while true
        nz_upper = floor((opt_sparsity + tol)*N^2);
        nz_lower = ceil((opt_sparsity - tol)*N^2);
        if nz_upper <= nz_lower
            tol = tol + tol_stp;
        else
            break
        end
    end

    while sparsity <= opt_sparsity - tol || sparsity >= opt_sparsity + tol

        A = gl_ar(dat, ba, ar_ord);

        sparsity = sum(A(:)<ztol)/length(A(:)); 

        S = [S sparsity];

        Sz = S - opt_sparsity;

        if abs(Sz(end))+abs(Sz(end-1)) ~= abs(Sz(end)+Sz(end-1))
            stp = stp/2;
    %     elseif sum(diff(S_end)) == 0
    %         stp = stp+1;
    %     else
    %         stp = stp_init;
        end

        ds = sparsity-opt_sparsity;
        if ds >= 0 && ba-stp>0
            ba = ba - stp;
        else
            ba = ba + stp;
        end
        
        if length(S) >= 100
            tol = tol + tol_stp;
        end
    end
    
    stp = 10^(floor(log10(ba)));

end