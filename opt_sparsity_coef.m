function [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, ztol, stp, tol, S, BA)
    
    % parameters
    opt_sparsity = 0.6;
    sparsity = 0;
    
    tol_stp = 0.001;
    k = 0;
    
    while sparsity <= opt_sparsity - tol || sparsity >= opt_sparsity + tol

        A = gl_ar(dat, ba, ar_ord);

        numz = sum(A(:)<ztol);
        sparsity = numz/length(A(:)); 

        S = [S sparsity];
        BA = [BA ba];

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

        k = k+1;
        if k > 100
            tol = tol + tol_stp;
        end
    end


end