function my_mkdir(pth, varargin)


    if (nargin == 1 || (nargin == 2 && isnumeric(varargin{1}))) && ~exist(pth, 'dir')
        mkdir(pth);
        return
    end
    
    n = 1;
    if isnumeric(varargin{1})
        if varargin{1} ~= 1
            return
        end
        n = 2;
    end

    for ii = n:nargin-1

        typ = varargin{ii};

        if ~ischar(pth) || ~ischar(typ)
            error('Make sure directories and file types are character inputs')
        elseif ~exist(pth, 'dir')
            mkdir(pth);
        elseif isnumeric(typ)
            if typ ~= 1
                hold = false;
            end

        elseif strcmp(typ, 'rmdir')
            rmdir(pth,'s')
            mkdir(pth);
            % Outline of code to remove a subset of the directories
%             d = dir(pth);
%             d = {d.name};
%             d(cellfun(@(x) strcmp(x(1), '.'), d)) = [];
%             for n = 1:length(d)
%                 rmdir(sprintf('%s/%s',pth,d{n}),'s')
%             end
        else
            fp = dir(fullfile(pth, typ));
            del = {fp.name};

            for c = 1:length(del)
                delete(sprintf('%s/%s', pth, del{c}));
            end
        end

    end



end