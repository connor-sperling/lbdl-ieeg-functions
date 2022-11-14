function combs = var_condition_combs(cond_set)  

    N = length(cond_set);
    switch N
        case 1
            combs = cond_set{1};
        case 2
            [ca, cb] = ndgrid(cond_set{1}, cond_set{2});
            combs = [ca(:), cb(:)];
        case 3
            [ca, cb, cc] = ndgrid(cond_set{1}, cond_set{2}, cond_set{3});
            combs = [ca(:), cb(:), cc(:)];
        case 4
            [ca, cb, cc, cd] = ndgrid(cond_set{1}, cond_set{2}, cond_set{3}, cond_set{4});
            combs = [ca(:), cb(:), cc(:), cd(:)];     
    end

end