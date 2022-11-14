function [A_deck, evn_seg, evn] = surrogate_evn_seg_to_A_deck(ba_init, EEG, study, break_endpoints_pad, subj_blacklist_set, ar_ord, ztol)

%             sig_lab = TvD(:,2);
%             loc_subj = loc(cellfun(@(x) strcmp(x,subj), loc.subj),:);
%             shift = randi([1001, 2999],1,1);
%             while any(X == shift)
%                 shift = randi([1001, 2999],1,1);
%             end
%             X(m) = shift;
% 
ba = ba_init;      
S = 0;
BA = [];

[evn_seg, evn] = segment_channels_per_event_BREAK(EEG, {}, study, break_endpoints_pad, subj_blacklist_set);

%             regions = loc_subj.region;
%             lab_ordered = loc_subj.channel_organized;
%             if length(lab_ordered) == length(sig_lab)
%                 [~,order] = ismember(lab_ordered, sig_lab);
%                 evn_seg = evn_seg(order,:,:);
%                 sig_lab = sig_lab(order);
%             else
%                 error('Table and Data dimensions do not match')
%             end
%             
%             rsplt = cellfun(@(x) strsplit(x, '-'), regions, 'uni', 0);
%             region_only = cellfun(@(x) x{2}, rsplt, 'uni', 0);
%             wm_msk = cellfun(@(x) strcmp(x, 'WM') | strcmp(x, 'U') | strcmp(x, 'blanc') | strcmp(x, 'out'), region_only);
%             
%             lab_ordered(wm_msk,:) = [];
%             sig_lab(wm_msk,:) = [];
%             evn_seg(wm_msk,:,:) = [];
%             
%             N = size(evn_seg,1);
%             L = length(evn);
%             if N <= 2
%                 continue
%             end
N = size(evn_seg,1);
L = length(evn);
A_deck = zeros(N,N,L);
for ii = 1:L % loop thru stimulus event files
    dat = evn_seg(:,:,ii);
    if ii == 1
        [stp, tol] = init_stepsize(dat, ba, ar_ord, ztol, S);
    end
    [S, BA] = opt_sparsity_coef(dat, ba, ar_ord, ztol, stp, tol, S, BA);
    ba = BA(end);
    A_deck(:,:,ii) = gl_ar(dat, ba, ar_ord);
end