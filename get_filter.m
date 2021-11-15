function [b,a] = get_filter(band, fs)

if strcmp(band, 'HFB') 
    Wp = [70 150]/(fs/2); % passband
    Ws = [60 160]/(fs/2); % stopband
    Rp = 3; % passband ripple
    Rs = 40; % stopband ripple
    [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
elseif strcmp(band, 'LFP')
    Wp = 30/(fs/2);
    Ws = 35/(fs/2);
    Rp = 3;
    Rs = 50;
    [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
end

[n,Ws] = cheb2ord(Wp,Ws,Rp,Rs); % find the order of the filter
[b,a] = cheby2(n,Rs,Ws); % get coeffs for chebyshev filter

end