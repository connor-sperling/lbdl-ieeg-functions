function imp_est_per_channel_event(subjs_dir, study, ref, locks, bands, fs, location, atlas, abr, ztol)

M = 10;

dpth = sprintf('%s/thesis/directed_connectivity/impulse_estimation/data/%s/adjacency_matricies', subjs_dir, study);
cmpth = sprintf('%s/thesis/directed_connectivity/impulse_estimation/plots/%s/connectivity_maps', subjs_dir, study);

xl_dir = sprintf('%s/Excel Files',subjs_dir);
loc_key_file = sprintf('%s/localization_key.xlsx',xl_dir);
if ~exist(loc_key_file, 'file')
    error('Please make a localization key excel file called "localization_key" in your Excel Files directory')
end

if strcmp(location, 'San_Diego')
    subjs = dir(sprintf('%s/sd*', subjs_dir));
else
    subjs = dir(sprintf('%s/pt*', subjs_dir));
end
subjs = {subjs.name};

for p = 1:length(subjs) % loop thru patients
subj = subjs{p};
% if strcmp(subj, 'sd09') || strcmp(subj, 'sd10')
%     continue
% end
stddir = sprintf('%s/%s/analysis/%s',subjs_dir,subj,study);
if exist(stddir, 'dir') % check if study exists for patient
for lockc = locks % loop thru time locks
lock = char(lockc);
for bandc = bands
band = char(bandc);

% if strcmp(subj,'sd14') && strcmp(lock,'stim') && strcmp(band,'LFP') %|| strcmp(subj,'sd10') && strcmp(lock,'stim') && strcmp(band,'HFB')
%     continue
% end
fprintf('%s %s %s\n',subj,lock,band)
my_mkdir(cmpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))
my_mkdir(dpth, sprintf('%s_%s_%s_%s_*',subj, ref, lock, band))

dat_dir = sprintf('%s/%s/analysis/%s/%s/%s/condition/data/%s', subjs_dir, subj, study, ref, lock, band);

cd(dat_dir)
dfiles = dir('*GRAY.mat');
dfiles = {dfiles.name}; % all stimuls event files

if abr % For connectivity maps
    xl_nm = sprintf('significant_GRAY_%s_%s_%s_%s_%s_localization',study,ref,lock,band,atlas);
    loc = readtable(sprintf('%s/%s.xlsx',xl_dir,xl_nm));
else
    loc = [];
end
    for n = 1:length(dfiles)
        fname = dfiles{n}; % file name
        if ~strcmp(fname(1),'.')  % avoid hidden files and singleton sig data
            fsplt = strsplit(fname, '_');
            evn_nm = fsplt{4}; % event name
            evn_nm = erase(evn_nm,'.mat');
            load(sprintf('%s/%s',dat_dir,fname), 'evn_seg')
            if size(evn_seg,1) <= 2
                break
            end
            N = size(evn_seg,1);
            A = zeros(N, N);
            for i = 1:N        
                xo = evn_seg(i,:)';
                % lo = sig_lab{i};
                xi = evn_seg';
                xi(:, i) = [];

                data = iddata(xo,xi,1/fs);
                h = impulseest(data,M);
                hvec = getpvec(h);
                for j = 1:N-1
                    hji = hvec((j-1)*(M+1)+1:j*(M+1)-1);
                    hi(:,j) = hji;
                    [F, f] = freqz(hji,1,1024,fs);
                    Hi(j,:) = abs(F);
                end
                
                w = sum(abs(hi))';

                A(1:i-1,i) = w(1:i-1);
                A(i+1:N,i) = w(i:end);
                
                H(:,:,i) = [Hi(1:i-1,:); zeros(1,size(Hi,2)); Hi(i:end,:)];
            end
            
            plot_connectivity_map(A, subj, ref, lock, band, cmpth, loc, ztol, 'event', evn_nm);
            save(sprintf('%s/%s_%s_%s_%s_%s_adjacency.mat',dpth,subj,ref,lock,band,evn_nm), 'A')
            save(sprintf('%s/%s_%s_%s_%s_%s_freq-response.mat',dpth,subj,ref,lock,band,evn_nm), 'H', 'f')
        end
    end
    
end
end
end
end
end
