function subjs = get_subjects()

subjs_dir = '';
xl_dir = '';
% set path to subjects directory
if contains(xl_dir, 'San_Diego')
    subjs = dir(sprintf('%s/sd*', subjs_dir)); 
else
    subjs = dir(sprintf('%s/pt*', subjs_dir));
end
subjs = {subjs.name}; % makes list of subjects found
end