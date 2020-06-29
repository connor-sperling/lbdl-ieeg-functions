function my_mkdir(varargin)

    for ii = 1:2:nargin-1

        pth = varargin{ii};
        typ = varargin{ii+1};

        if ~ischar(pth) || ~ischar(typ)
            error('Make sure directories and file types are character inputs')
        elseif ~exist(pth, 'dir')
            mkdir(pth);
        else
            fp = dir(fullfile(pth, typ));
            del = {fp.name};

            for c = 1:length(del)
                delete(sprintf('%s/%s', pth, del{c}));
            end
        end
        
    end


end