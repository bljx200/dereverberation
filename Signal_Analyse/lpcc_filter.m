clear all;
[x_in,fs] = audioread('ly_reverberant_signal.wav');
x_in=x_in/max(abs(x_in));
%---------------����Ԥ��ǿ-----------------
a=0.97;
x=filter([1,-a],[1],x_in);
x=x/max(abs(x));
%---------------��֡�Ӵ�-----------------
wlen = 0.02*fs;%֡��
inc = 0.3*wlen;%֡��
overlap = wlen-inc;%֡��
xseg = enframe(x,hanning(wlen),inc)';%'֮����֡��*֡��
fn = size(xseg,2);%֡��
%frameTime = frame2time(fn,wlen,inc,Fs);
%%
y_filter = sgolayfilt(x,12,15);
