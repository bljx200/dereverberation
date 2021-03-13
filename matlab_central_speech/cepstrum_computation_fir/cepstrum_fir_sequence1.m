function [b,L,stitle,freq,BNmag_ph,phase_rad,nfft,cepl,xhat1,xhats3]=cepstrum_fir_sequence1(...
        alpha,Np)
%
% function to generate fir sequence 1 and compute its complex cepstrum
% signal 1: H(z)=1+alpha*z^{-100}; h1[n]=\delta[n]+\alpha \delta[n-Np]
%
% Inputs:
%   alpha: echoed signal gain
%   Np: echo signal delay
%
% Outputs:
%   b: fir sequence 1
%   L: length of fir sequence 1
%   stitle: title for plots
%   freq: frequency axis for plots
%   BNmag_ph: magnitude and phase for log magnitude spectrum of sequence
%   phase_rad: phase of log spectrum
%   nfft: fft size for cepstral computation
%   cepl: number of cepstral coefficients to compute
%   xhat1: complex cepstrum based on roots of fir sequence polynomial
%   xhats3: complex cepstrum using ffts

% set fft size (nfft), sequence index, n
    nfft=2048;
    n=0:nfft-1;
    
% parameters of analytical computation
%   cepl: length of complex cepstrum plotted for fir signal
    cepl=600;
%   L: length of fir signal
    L=Np+1;
%   fs: sampling rate for signal
    fs=10000;
    
% generate impulse plus delayed impulse; x1[n]=delta[n]+alpha*delta[n-Np]
    b(1:L)=0;
    b(1)=1;
    b(L)=alpha;
    
% solve for complex cepstrum based on numerator polynomial roots
    z=roots(b);
    [xhat1]=poly_roots_complex_cep(z,L,cepl,fs);

% now use Matlab routine to solve for complex cepstrum       
% compute cepstra using toolbox functions
    [xhat2,nd]=cceps(b,nfft);
    xhats2=[xhat2(nfft-cepl+1:nfft) xhat2(1:cepl+1)];
    
% compute spectrum, phase, unwrapped phase, compute complex cepstrum using
% regular matlab code
    BN=fft(b,nfft);
    phase_rad=angle(BN);
    phase_rad_unwrap=unwrap(phase_rad);
    BNmag_ph=log(abs(BN))+phase_rad_unwrap*i;
    xhat3=ifft(BNmag_ph,nfft);
    xhats3=[xhat3(nfft-cepl+1:nfft) xhat3(1:cepl+1)];
    xhats3=real(xhats3);
    
% generate frequency scale
    freq=0:fs/nfft:fs/2;
    
    stitle=sprintf('H(z)=1+alpha*z-Np; alpha: %6.2f, Np: %d, nfft:%d, cepl:%d ',...
            alpha,Np,nfft,cepl);

end

