function electrode_psd(EEG, evn, evni, rtm, pth, foc_nm)

    plt_dir = sprintf('%s/plots', pth);
    dat_dir = sprintf('%s/data', pth);
    
    fs = EEG.srate; 
    labs = {EEG.chanlocs.labels}; % channel labels
    dat = [EEG.data];
    pt_id = strsplit(EEG.setname, '_');
    pt_nm = pt_id{1};
    L = length(labs);
    N = length(evn);
    p = 200;
   
    dat = transpose(downsample(dat',2));
    fs = fs/2;
    evni = round(evni/2);
    rtm = round(rtm/2);
    
    av_rtm = mean(rtm);
    av_rtmi = round(av_rtm./1000 *fs);
    
    t_an_st = 0;
    t_an_en = av_rtmi + 400;
    t_bl_st = -500;
    t_bl_en = 0;
     
    an_t = t_an_en - t_an_st; % Total time in event window
    bl_t = t_bl_en - t_bl_st; % Total time in baseline window
    
    an_st  = evni + floor(t_an_st./1000 *fs); % Idx of lock + (-) baseline window st time
    an_en  = evni + floor(t_an_en./1000 *fs); % Idx of lock + (-) baseline window end time
    bl_st  = evni + floor(t_bl_st./1000 *fs); % Idx of lock + (-) baseline window st time
    bl_en  = evni + floor(t_bl_en./1000 *fs); % Idx of lock + (-) baseline window end time
    
    Ppo_mv = zeros(N, p/2);
    Pbl_mv = zeros(N, p/2);
    Ppo_mv = [];
    Pbl_mv = [];
    for kk = 1:L  
        x = dat(kk, :);
        for jj = 1:N
            x_po = x(an_st(jj):an_en(jj));
            x_bl = x(bl_st(jj):bl_en(jj));
            
%             [ppo_mv, wpo] = psd_mv(x_po, p);
%             [pbl_mv, ~] = psd_mv(x_bl, p);
            [ppo_mv, f] = pmtm(x_po, 4, 2^10, fs);
            [pbl_mv, f] = pmtm(x_bl, 4, 2^10, fs);
%             Ppo_mv(jj,:) = ppo_mv;
%             Pbl_mv(jj,:) = pbl_mv;
            Ppo_mv = [Ppo_mv; ppo_mv'];
            Pbl_mv = [Pbl_mv; pbl_mv'];
        end         
        
        Pxx = (Ppo_mv - Pbl_mv)./Pbl_mv;
        
        figure('visible', 'off')
        plot(f*(fs/2), mean(Pxx,1), 'linewidth', 1.5)
        line([0 fs/2], [0 0], 'color', 'k', 'linewidth', 2)
        xlim([0 fs/2])
        
        Pxx = mean(Pxx,1);
        
        saveas(gca, sprintf('%s/%s_%s_%s_%s_PSD.png', plt_dir, foc_nm, pt_nm, labs{kk}, EEG.ref))
        save(sprintf('%s/%s_%s_%s_%s_PSD.mat', dat_dir, foc_nm, pt_nm, labs{kk}, EEG.ref), 'Pxx');
        close
    end    
end


% fs = 512;
% dat_dir = '/Users/connor-home/Desktop/electrode_power/data';
% cd(dat_dir)
% 
% files = dir('ALL_sd08*');
% dfiles = {files.name};
% files = dir('ALL_sd09*');
% dfiles = [dfiles {files.name}];
% load(dfiles{1});
% wn = 0:1/size(Pxx,2):1-1/size(Pxx,2);
% PXX = zeros(length(dfiles), size(Pxx, 2));
% PXX(1,:) = mean(Pxx,1);
% 
% for i = 2:length(dfiles)
%     i
%     load(dfiles{i});
%     PXX(i,:) = mean(Pxx,1);
% end
% 
% figure
% plot(wn*(fs/2), mean(PXX,1), 'linewidth', 1.5)
% line([0 fs/2], [0 0], 'color', 'k', 'linewidth', 2)
% xlim([0 fs/2])