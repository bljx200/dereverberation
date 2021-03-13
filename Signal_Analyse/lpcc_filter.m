clear all;
[x_in,fs] = audioread('ly_reverberant_signal.wav');
x_in=x_in/max(abs(x_in));
%---------------语音预增强-----------------
a=0.97;
x=filter([1,-a],[1],x_in);
x=x/max(abs(x));
%---------------分帧加窗-----------------
wlen = 0.02*fs;%帧长
inc = 0.3*wlen;%帧移
overlap = wlen-inc;%帧叠
xseg = enframe(x,hanning(wlen),inc)';%'之后是帧长*帧数
fn = size(xseg,2);%帧数
%frameTime = frame2time(fn,wlen,inc,Fs);
%%
y_filter = sgolayfilt(x,12,15);
