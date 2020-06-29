xl = xlsread('L:/iEEG_San_Diego/Functions/iEEG_SD_pts.xlsx', 2, 'H2:H118');
msk = zeros(2,length(evns)); 
for ii = 1:length(xl)
    a = evns == xl(ii);
    msk = msk + a;
end
 sum(msk(1,:))
 sum(msk(2,:))