
pdir = '/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs/plots/connectivity_maps/Stroop_CIC-CM';
cd(pdir)
figs = dir('*.fig');
figs = {figs.name};
nm_splt = cellfun(@(x) strsplit(x, '_'), figs, 'uni', 0);
evn_nm = cellfun(@(x) x{5}, nm_splt, 'uni', 0);
evn_splt = cellfun(@(x) strsplit(x, '-'), evn_nm, 'uni', 0);
trial_num = cellfun(@(x) str2double(x{1}), evn_splt);
[~,ord] = sort(trial_num);
figs = figs(ord);

for i = 1:length(figs)
    f = openfig(figs{i});
    frame = getframe(f);
    im{i} = frame2im(frame);
end

filename = 'testAnimated.gif'; % Specify the output file name
for i = 1:length(figs)
    [A,map] = rgb2ind(im{i},256);
    if i == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end