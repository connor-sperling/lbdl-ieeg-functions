function loadbar(n, sz)

    percent = floor(100*n/sz);
    
    p = floor(100*(n-1)/sz);

    if mod(percent, 10) == 0
  
        msg = sprintf('  %d%% done...', percent);
        disp(msg)
        
    elseif mod(p, 10) > 5 && mod(percent, 10) < 5
        
        msg = sprintf('  %d%% done...', percent-mod(percent, 10));
        disp(msg)
        
    end
    
end