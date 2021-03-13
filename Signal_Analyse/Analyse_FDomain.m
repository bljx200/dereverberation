clear all;
nfft=512;%F变换的点数
[x,fs] = audioread('origin_signal.wav');
x=x/max(abs(x));
%-----STFT-----
wlen = 240;%数越大，f精度越高；数越小，t精度越高
inc = 80;
overlap=wlen-inc;
win = hanning(wlen);
y=enframe(x,win,inc)';
fn = size(y,2); %帧数

Y=fft(y);%之后还得手动取一半：1~nfft/2+1
%或者
%y=stftms(x,win,nfft,inc);%直接就是一半
%%
%-----------语谱图--------------

frameTime = (((1:fn)-1)*inc+wlen/2)/fs;
W2 = wlen/2+1;%此程序fft的长度=wlen，取一半
n2 = 1:W2;
freq = (n2-1)*fs/wlen;%fft后的频率刻度
clf%初始化图形
set(gcf,'Position',[20 100 600 500]);
%axes('Position',[0.1 0.1 0.85 0.5]);
imagesc(frameTime,freq,abs(Y(n2,:)));
axis xy;
ylabel('Frequency/Hz');
xlabel('Time/s');
title('语谱图');

%调整颜色
m=64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
colormap(SpecColorMap(m,Colors));%P41页
%%
%---------短时PSD------------
w_wlen=hanning(200);
w_overlap = 195;
[Pxx] = pwelch_2(x,wlen,overlap,w_wlen,w_overlap,nfft);
frameNum = size(Pxx,2);
frameTime = frame2time(frameNum,nfft,inc,fs);
freq = (0:nfft/2)*fs/nfft;
%图
imagesc(frameTime,freq,Pxx);
axis xy
xlabel('Frequency/Hz');
ylabel('Time/s');
title('短时PSD');
%颜色
m=256;
m=64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
colormap(SpecColorMap(m,Colors));
%%
%-----------求LPC----------------
est_x=zeros(size(y));
err = zeros(size(y));
Y = zeros(size(y));
p=12;%LPC阶数
%p70页
for i=1:fn
yi=y(:,i);%按顺序取一帧
ar=lpc(yi,p);%线性预测变换
%Y(:,i)=lpcar2ff(ar,255);%
est_x(:,i) = filter([0 -ar(2:end)],1,yi);
%est_x(((i-1)*wlen+1):(i*wlen)) = filter([0 -ar(2:end)],1,yi);%用LPC求预测估算值
%err(:,i)=y1-est_x;%求出预测误差
end
xlp=zeros(size(x));
for i=1:fn
xlp((1+(i-1)*inc):(1+(i-1)*inc+inc),:)=est_x((2+end)/2-inc/2:(2+end)/2+inc/2,i);
end
%%
%图
subplot 311
plot(x);axis tight;
title('波形');

subplot 323
plot(y);xlim([0 wlen]);
title('一帧波形');

subplot 324
plot(est_x);xlim([0 wlen]);
title('预测值');

subplot 325
plot(abs(Y));xlim([0 wlen]);
title('LPC频谱');

subplot 326
plot(err);xlim([0 wlen]);
title('预测误差');
%%
%-------------倒谱-----------
yi=y(:,1000);%取一帧
N=size(y,2);
S=fft(yi);
Sa = log(abs(S));
sa=ifft(Sa);
ylen=length(sa);
for i=1:ylen/2
    sal(i)=sa(ylen/2+1-i);
end
for i=(ylen/2+1):ylen
    sal(i)=sa(i+1-ylen/2);
end
%图

plot(sal);
title('第1000帧语音的倒谱');
%%
%--------mfcc-------
x_mfcc = mfcc_m(x,fs,12,wlen,inc);