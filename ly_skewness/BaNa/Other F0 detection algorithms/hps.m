function [pitch]=hps(x,Fs)
%
% Pitch detection using Harmonic Product Spectrum (HPS)
% M. R. Schroeder, “Period histogram and product spectrum: New methods
% for fundamental frequency measurement,” Journal of the Acoustical
% Society of America, vol. 43, pp. 829–834, 1968.
%
% Code written by He Ba, University of Rochester
%
fx=log(abs(fft(x.*hann(length(x)),2^16)));
freq_resolution = Fs/(2^16);
fx1=fx(1:2:2^16); %harmonic compression
fx2=fx(1:3:2^16);
fx3=fx(1:4:2^16);
fx4=fx(1:5:2^16);
hpslength=length(fx4);
HPSx=fx(1:hpslength)+fx1(1:hpslength)+fx2(1:hpslength)+fx3(1:hpslength)+fx4(1:hpslength);
Frequencies=0:freq_resolution:Fs;
[m,I]=max(exp(HPSx(1:hpslength)));
pitch=Frequencies(I);