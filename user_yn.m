function binary = user_yn(pmt, varargin)


    switch pmt
        case 'exit prog? 1'
            msg = '\nYou cancelled the file selection. Would you like to exit the program?';
            
        case 'load file?'
            msg = '\nWould you like to load in this file?';
            
        case 'change code?'
            msg = '\nWould you like to change the event code names?';
            
        case 'bipolar referenced?'
            msg = '\nIs this bipolar referenced data?';
            
        case 'rereference?'
            msg = '\nWould you like to re-reference this data?';
            
        case 'bipolar reference?'
            msg = '\nWould you like to bipolar reference this data?';
            
        case 'save evn info?'
            msg = '\nDo you want to save this updated stimulus event information?';
            
        case 'save EEG?'
            msg = '\nDo you want to save your work?';
            
        case 'process another?'
            msg = '\nWould you like to process another patient?';
            
        case 'prep ALL again?'
            msg = sprintf('\nIt looks like you have already processed this data across ALL events for %s analysis\nWould you like to do it again?',  varargin{1});
            
        case 'fba ALL again?'
            msg = sprintf('\nIt looks like you have already processed %s analysis over ALL events for %s\nWould you like to do it again?', varargin{1}, varargin{2}); 
            
        case 'ret iep?'
            msg = '\nReturn to iEEG processor?';
        
        case 'artifact rem?'
            msg = '\nRemove artifacts?';
            
        case 'keep event rejection?'
            msg = '\nKeep event rejection?';
            
        case 'keep channel rejection?'
            msg = '\nKeep channel rejection?';
            
    end
        yn = '';
        while ~strcmp(yn, 'y') && ~strcmp(yn, 'yes') && ~strcmp(yn, 'n') && ~strcmp(yn, 'no')
            yn = input([msg ' (y/n)\n--> '], 's');
        end

        if strcmp(yn, 'y') || strcmp(yn, 'yes')
            binary = 1;
        elseif strcmp(yn, 'n') || strcmp(yn, 'no')
            binary = 0;
        else
            error('Binary undecided')
        end

end