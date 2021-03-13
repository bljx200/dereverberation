% load clean speech signal and room impulse response function, all sampled
% at 16 kHz
% load sig and im
load 'data\sample';%加载原始语音和房间脉冲信号

% generate reverberant speech
im = reshape(im,length(im),1);
rev = fftfilt(im,sig);

% inverse filter
[inv, com_im1]  = inverse_filter(rev, im); 

% spectral subtraction
derev = spec_sub_derev(inv,16000);

% output as wav files
wavwrite(sig/(max(abs(sig)))*0.95,16000,'wav\org.wav');%原始的语音
wavwrite(rev/(max(abs(rev)))*0.95,16000,'wav\rev.wav');%混响后的语音
wavwrite(inv/(max(abs(inv)))*0.95,16000,'wav\inv.wav');%逆滤波的语音
wavwrite(derev/(max(abs(derev)))*0.95,16000,'wav\derev.wav');%去混响后的语音