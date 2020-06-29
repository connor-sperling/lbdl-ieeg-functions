function x = test_func(x, str)

    if ischar(str)
        disp(str)
    end
    
    
    [r,c] = size(x);
    if r == c
        disp('This is a matrix')
        x = mean(x);
    elseif r > c
        disp('This is a column vector')
    else
        disp('This is a row vector')
        
    end
    figure
    scatter(1:length(x), x)
        
    x = 2*x;

end