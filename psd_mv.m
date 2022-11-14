function [pxx_mv,w] = psd_mv(x,p)

    r = 1/p*xcorr(x(1:p),x(1:p));
    M = length(r);  
    R = toeplitz(r((M+1)/2:end));
    N = size(R,1);
    [V,D] = eig(R);
    d = 1./(abs(diag(D))+eps);
    W = abs(fft(V,N)).^2;
    px = fftshift((1+p)./(W*d));
    pxx_mv = px(N/2+1:end);
    w = 0:2/N:1-1/N;

end