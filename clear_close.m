
clear
close all
clc

while true
    
    
    i = input('\n> ', 's');
    if strcmp(i, 'cls')
        disp('  ')
        break
    end
    
    clearvars -except i
    close all
    
    

    if strcmpi(i,'stay')
        while true
            j = input('\n> ', 's');
            if strcmp(j, 'go')
                break
            end
            eval(j)
        end
    else
        eval(i)
    end
    
    
end

