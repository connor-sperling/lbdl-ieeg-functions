function test1026(a, varargin)
disp(a+10)
iscell(varargin)
for ii = 1:length(varargin)
    disp(varargin)
    disp(varargin{ii})

end
end