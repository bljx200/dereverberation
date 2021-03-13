clear all;
nfft=512;%F�任�ĵ���
[x,fs] = audioread('origin_signal.wav');
x=x/max(abs(x));
%-----STFT-----
wlen = 240;%��Խ��f����Խ�ߣ���ԽС��t����Խ��
inc = 80;
overlap=wlen-inc;
win = hanning(wlen);
y=enframe(x,win,inc)';
fn = size(y,2); %֡��

Y=fft(y);%֮�󻹵��ֶ�ȡһ�룺1~nfft/2+1
%����
%y=stftms(x,win,nfft,inc);%ֱ�Ӿ���һ��
%%
%-----------����ͼ--------------

frameTime = (((1:fn)-1)*inc+wlen/2)/fs;
W2 = wlen/2+1;%�˳���fft�ĳ���=wlen��ȡһ��
n2 = 1:W2;
freq = (n2-1)*fs/wlen;%fft���Ƶ�ʿ̶�
clf%��ʼ��ͼ��
set(gcf,'Position',[20 100 600 500]);
%axes('Position',[0.1 0.1 0.85 0.5]);
imagesc(frameTime,freq,abs(Y(n2,:)));
axis xy;
ylabel('Frequency/Hz');
xlabel('Time/s');
title('����ͼ');

%������ɫ
m=64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
colormap(SpecColorMap(m,Colors));%P41ҳ
%%
%---------��ʱPSD------------
w_wlen=hanning(200);
w_overlap = 195;
[Pxx] = pwelch_2(x,wlen,overlap,w_wlen,w_overlap,nfft);
frameNum = size(Pxx,2);
frameTime = frame2time(frameNum,nfft,inc,fs);
freq = (0:nfft/2)*fs/nfft;
%ͼ
imagesc(frameTime,freq,Pxx);
axis xy
xlabel('Frequency/Hz');
ylabel('Time/s');
title('��ʱPSD');
%��ɫ
m=256;
m=64;
LightYellow = [0.6 0.6 0.6];
MidRed = [0 0 0];
Black = [0.5 0.7 1];
Colors = [LightYellow; MidRed; Black];
colormap(SpecColorMap(m,Colors));
%%
%-----------��LPC----------------
est_x=zeros(size(y));
err = zeros(size(y));
Y = zeros(size(y));
p=12;%LPC����
%p70ҳ
for i=1:fn
yi=y(:,i);%��˳��ȡһ֡
ar=lpc(yi,p);%����Ԥ��任
%Y(:,i)=lpcar2ff(ar,255);%
est_x(:,i) = filter([0 -ar(2:end)],1,yi);
%est_x(((i-1)*wlen+1):(i*wlen)) = filter([0 -ar(2:end)],1,yi);%��LPC��Ԥ�����ֵ
%err(:,i)=y1-est_x;%���Ԥ�����
end
xlp=zeros(size(x));
for i=1:fn
xlp((1+(i-1)*inc):(1+(i-1)*inc+inc),:)=est_x((2+end)/2-inc/2:(2+end)/2+inc/2,i);
end
%%
%ͼ
subplot 311
plot(x);axis tight;
title('����');

subplot 323
plot(y);xlim([0 wlen]);
title('һ֡����');

subplot 324
plot(est_x);xlim([0 wlen]);
title('Ԥ��ֵ');

subplot 325
plot(abs(Y));xlim([0 wlen]);
title('LPCƵ��');

subplot 326
plot(err);xlim([0 wlen]);
title('Ԥ�����');
%%
%-------------����-----------
yi=y(:,1000);%ȡһ֡
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
%ͼ

plot(sal);
title('��1000֡�����ĵ���');
%%
%--------mfcc-------
x_mfcc = mfcc_m(x,fs,12,wlen,inc);