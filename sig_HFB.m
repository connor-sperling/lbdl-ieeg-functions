%% Initiate
subj= 'SD06';
block = 'Naming';

%%
srate = 1e3;
st_tp = round((1000*srate)/1000);
en_tp = round((3000*srate)/1000);
window=st_tp+1:en_tp;
length_win=round((50*srate)/1000);
nwin=floor(size(window,2)/length_win);
windows=zeros(nwin,length_win);
ttl_chan = 151;
fname = 'iEEG_SD_pts.xlsx';
sheet = 3;
chnl_range = 'A2:A175';
chnl_rej = xlsread(fname,sheet,chnl_range);

x=1;
for w = 1:nwin
    windows(w,:)=window(x):window(x+(length_win-1));
    x=x+length_win;
end
thresh = 0;
chunksize =50/1000*srate;
q = 0.05;
%% calculate difference between target and decision per electrode using unpaired ttest for every time point
% elecs = 124;% depends on the patient
cnt = 1;
clear TvD
for m = 1:ttl_chan
    if ~ismember(m,chnl_rej)
        trials_data_strct = load (['ALL',num2str(m),'.mat']);
        trials_data = trials_data_strct.chnl_evnt;
        fprintf('\n%i...',m)
        pvals = [];
        hval = [];
        % unpaired ttest at every point
        x=1;
        for w = 1:nwin
            win=window(x):window(x+(length_win-1));
            [h, p] = ttest2(single(zeros(size(trials_data(:,1)))),...
                mean(trials_data(:,win),2), q,'left','unequal');
            %The result h is 1 if the test rejects the null hypothesis at
            %the 5% significance level, and 0 otherwise. p-value is the
            %probability that the results from your sample data occurred by chance
            x=x+length_win;
            pvals = [pvals p];
            hval = [hval h];
        end
        clear x w win
        %fdr correct
        [pthr, pcor, padj] = fdr2(pvals,q);
        
        %find starting indicies of significance groups
        H = pvals<pthr;
        
        %identify if electrode is significant (has significant chunk that is >10% baseline)
        sig=H;
        difference = diff(H);
        start_idx = windows(find(difference == 1),1)+1;
        end_idx = windows(find(difference == -1),length_win);
        if numel(start_idx)>numel(end_idx) %the last chunk goes until the end
            end_idx = [end_idx;windows(nwin,length_win)]; 
        elseif numel(start_idx)<numel(end_idx) %starts immediate significant
            start_idx = [st_tp;start_idx];
        end
        if ~isempty(start_idx) && (start_idx(1) > end_idx(1)) % starts immediately significant
            start_idx = [st_tp;start_idx];
        end
        if ~isempty(start_idx) && (end_idx(end) < start_idx(end)) %there is no end_idx - significant until end
            end_idx = [end_idx;windows(nwin,length_win)];
        end
        chunks = ((end_idx-start_idx)>=chunksize);
        if sum(chunks)==0
            fprintf('skipping electrode %i\n',m)
            continue
        end
        TvD_full{cnt,1} = m;
        TvD_full{cnt,2} = pthr; %corrected pvalue threshold
        TvD_full{cnt,3} = pvals; %original pvalues
        TvD_full{cnt,4} = [start_idx end_idx];
        TvD_full{cnt,5} = padj; %adjusted pvalues
        
        if ~isempty(start_idx)
            chunks = ((end_idx-start_idx)>=chunksize);
            if sum(chunks)>0 %at least 1 chunk is > chunksize (ex 50ms)
                TvD{cnt,1} = m;
                TvD{cnt,2} = pthr; %corrected pvalue threshold
                TvD{cnt,3} = pvals; %original pvalues
                TvD{cnt,4} = [start_idx(chunks) end_idx(chunks)];
                TvD{cnt,5} = padj; %adjusted pvalues
            end
            start_idx = start_idx(chunks); end_idx = end_idx(chunks);
        end
        cnt= cnt+1;
    end
end

clear trials_data_strct trials_data
%remove empty rows in TvD
emptyCells = cellfun('isempty', TvD);
TvD(all(emptyCells,2),:) = [];
save('TvD.mat','TvD_full','TvD','q','chunksize');

%plot significant electrodes
stim = 0/1000*srate;
ticks_tp = round(250./1000*srate); %plotting

start_time_window = -1000;
tm_st  = round( start_time_window ./1000*srate);
tm_en  = round( 2000 ./1000*srate);
st_tp = 0;
en_tp = round( 1000 ./1000*srate);

plot_jump = 500;
jm = round(plot_jump./1000*srate);
for m = 1:ttl_chan
    if ~ismember(m,chnl_rej)
        cnt = find([TvD{:,1}]==m);
        if cnt
            fprintf('e%i\n',m)
            trials_data_strct = load (['ALL',num2str(m),'.mat']);
            trials_data = trials_data_strct.chnl_evnt;
            figure('color','white');
            set(gcf,'Units','pixels','Position',[100 100 800 600])
            semT = squeeze(std(trials_data(:,:))/sqrt(size(trials_data,1)))';
            
            scalemax = max(max(squeeze(mean(trials_data(:,:)))+semT'));
            scalemin = min(min(squeeze(mean(trials_data(:,:)))-semT'));
            if scalemin > 0
                scalemin = -10;
            end
            h2 = shade_plot(tm_st:tm_en, squeeze(mean(trials_data(:,:))), semT',...
                rgb('steelblue'),0.5,1); hold on
            for z = 1:length((tm_st:jm:tm_en)), plot_str{z} = start_time_window...
                    +(z-1)*plot_jump; 
            end
            set(gca,'XTick',(tm_st:jm:tm_en),'XTickLabel',plot_str,'XTickMode',...
                'manual','Layer','top');
            xlim([tm_st tm_en])
            
            plot([stim stim] ,[scalemin scalemax], '--','LineWidth',2, 'Color',rgb('SlateGray')); hold on;
            xlabel('ms'); ylabel('% change from baseline');
            plot([tm_st tm_en], [0 0],'k','LineWidth',1); hold on
            plot([st_tp tm_en], [0 0],'k','LineWidth',3);
            start_idx = TvD{cnt,4}(:,1)+tm_st;
            end_idx = TvD{cnt,4}(:,2)+tm_st;
            
            for i = 1:length(start_idx)
                plot((start_idx(i):end_idx(i)), zeros(1,length(start_idx(i):end_idx(i))), 'r', 'LineWidth',3); hold on
                
            end
            title(sprintf('%s - e%i - one-sided - %s > zero for >%ims', subj, m, block, chunksize/srate*1000))
            axis tight
            grid on
            print('-dpng',sprintf('%s/e%i_%2.2f_%ims.png',pwd, m, q, chunksize))
            saveas(gcf, sprintf('%s/e%i_%2.2f_%ims.fig',pwd, m, q, chunksize))
            close
        end
    end
end
clear start_idx end_idx difference
