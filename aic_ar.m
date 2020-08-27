
close all
clear

subj = 'sd14';
band = 'NONE';
ref = 'bipolar';
iter = 1000;

cd(sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs/%s/analysis/Stroop_CIC-CM/%s/stim/condition/data/%s', subj, ref, band))
files = dir('*.mat');
files = {files.name};
mean_file = sprintf('allChanPerEvn_%s_bipolar_mean.mat', subj);
files(cellfun(@(x) strcmp(x, mean_file), files)) = [];

if strcmp(band,'NONE')
    band = 'RAW';
end
test_data = zeros(iter, 1+round(1024*.8));
Xe = zeros(1, iter);
Xc = zeros(1, iter);
n = 0;
for i = 1:iter
    
    xe = randi([1 length(files)]);  
    eventf = files{xe};
    load(eventf)
    
    Xe_nz = Xe(Xe > 0);
    rep_msk = false(1,length(Xe_nz));
    
    while true
        xc = randi([1 size(evn_seg,1)]);
        for j = 1:length(Xe_nz)
            rep_msk(j) = Xe(j) == xe & Xc(j) == xc;
        end
        if ~any(rep_msk)
            Xc(i) = xc;
            break
        else
            xe = randi([1 length(files)]);  
            eventf = files{xe};
            load(eventf)
            n = n+1;
        end
    end
    
    Xe(i) = xe;
    dat = evn_seg(xc, :);
    test_data(i, :) = dat;
end

maxN = 50;
tol = 0.1;
k = 0;
AICc = zeros(size(evn_seg,1), maxN); 
arg_knee = zeros(1, size(test_data,1));
for m = 1:size(test_data,1)
    thresh = .5;
    for n = 1:maxN
        a = ar(test_data(m,:), n, 'ls');
        AICc(m,n) = aic(a,'AICc');
    end
    
    poly_coef = polyfit(1:maxN, AICc(m,:), 5);
    AICpoly = polyval(poly_coef, 1:maxN);
    
    d_coef = polyder(poly_coef);
    d2_coef = polyder(d_coef);
    d3_coef = polyder(d2_coef);
    
    dAICpoly = polyval(d_coef, 1:maxN);
    d2AICpoly = polyval(d2_coef, 1:maxN);
    d3AICpoly = polyval(d3_coef, 1:maxN);

    ndAICpoly = -dAICpoly;
    [~, idx] = min(abs(ndAICpoly - .2*ndAICpoly(5)));
%     
%     figure
%     plot(1:maxN,dAICpoly)
%     hold on
%     plot(1:maxN, d3AICpoly)
%     scatter(idx, dAICpoly(idx))
%     
%     figure
%     plot(1:length(AICpoly),AICpoly)
%     hold on
%     scatter(1:maxN, AICc(m,:))
    
  
    arg_knee(m) = idx;

%     d2 = diff(diff(AICc(m,:)));
%     if strcmp(band,'LFP')
%         arg_knee(m) = find(d2 == min(d2),1)+2;
%     else
%         cand = find(abs(d2) < 1) + 2;
%         idx = find(diff(cand) <= 2, 1);
%         if isempty(cand)
%             cand = find(abs(d2)==min(abs(d2)))+2;
%         end
%         if length(cand) == 1
%             idx = 1;
%         elseif isempty(idx)
%             idx = find(diff(cand) == min(diff(cand)), 1);
%         end
%         arg_knee(m) = cand(idx);
%     end
end

mAICc = mean(AICc,1);
dmAICc = diff(mAICc);

sdir = '~/Documents/research/thesis/aic_ar order/';
figure
histogram(arg_knee)
ylabel('count')
xlabel('Knee of AICc curve')
title(sprintf('%s - %s - Distribution of AR order (%i iterations w/out rep)', subj, band, iter))
saveas(gca, sprintf('%s/ar_ord_dist_%s_%s_%i.png', sdir, subj, band, iter));

figure
scatter(1:maxN, mAICc)
ylabel('AICc')
xlabel('AR order')
title(sprintf('%s - %s - Average AICc wrt AR order', subj, band))
saveas(gca,  sprintf('%s/avg_aicc_curve_%s_%s_%i.png', sdir, subj, band, iter));