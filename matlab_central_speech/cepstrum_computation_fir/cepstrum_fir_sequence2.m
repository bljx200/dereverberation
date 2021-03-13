function [b,L,stitle,freq,BNmag_ph,phase_rad,nfft,cepl,xhat1,xhats3]=cepstrum_fir_sequence2(...
        alpha1,Np)
%
% function to generate fir sequence 2 and compute its complex cepstrum
%   sequence 2: (Np+1) samples of sinewave of period Np samples
%   weighted by alpha1^n; h2[n]=cos(2\pi n/(Np)) \alpha1^n; 0 <= n <= Np 

%
% Inputs:
%   alpha1: signal parameter for scaling
%   Np: period of sinewave signal
%
% Outputs:
%   b: fir sequence 2
%   L: length of fir sequence 2
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
    cepl=200;
%   L: length of fir signal
    L=Np+1;
%   fs: sampling rate for signal
    fs=10000;
    
% generate fir sequence 2
	n1=0:Np;
	b(1:Np+1)=cos(2*pi*n1/(Np)).*(alpha1.^n1);
    
% solve for complex cepstrum based on numerator polynomial roots
    z=roots(b);
    [xhat1]=poly_roots_complex_cep(z,Np,cepl,fs);

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
    
    stitle=sprintf('length Np sinewave; alpha1: %6.2f, nfft:%d, cepl:%d \n',alpha1,nfft,cepl);

end