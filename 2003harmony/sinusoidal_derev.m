%����ɨƵ�ź�
fs=44100;
T=1/fs;
T1=2;
t=0:T:T1;
F0=100;
F1=7000;
x = chirp(t,F0,T1,F1); 

%����RIR
c = 340;       % Sound velocity (m/s)
room = [6 4 3];
beta = [0.75 0.75 0.75 0.75 0.75 0.75];      %Reflection coefficients
s = [2 3 1.5]; %Source 
mic = [4 1 2];
n=4096;
h = rir_generator(c, fs, mic, s, room, beta, n);
h=h/max(abs(h));

%����ӻ���
y=filter(h, 1, x);
y=y/max(abs(y));

%��֡
nfft=512;%F�任�ĵ���
wlen = 480;%��Խ��f����Խ�ߣ���ԽС��t����Խ��
inc = 80;
overlap=wlen-inc;
win = hanning(wlen);
yseg=enframe(y,win,inc)';
xseg=enframe(x,win,inc)';
fn_y = size(yseg,2); %֡��
fn_x = size(xseg,2); 
Y=fft(yseg);%֮�󻹵��ֶ�ȡһ�룺1~nfft/2+1
X=fft(xseg);

%����ɨƵ�źŵ�����ͼ
figure;
frameTime = (((1:fn_y)-1)*inc+wlen/2)/fs;
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
axis([0 inf 0 1e4]);


%��ɨƵ�źŵ�����ͼ
figure;
frameTime = (((1:fn_x)-1)*inc+wlen/2)/fs;
W2 = wlen/2+1;%�˳���fft�ĳ���=wlen��ȡһ��
n2 = 1:W2;
freq = (n2-1)*fs/wlen;%fft���Ƶ�ʿ̶�
clf%��ʼ��ͼ��
set(gcf,'Position',[20 100 600 500]);
%axes('Position',[0.1 0.1 0.85 0.5]);
imagesc(frameTime,freq,abs(X(n2,:)));
axis xy;
ylabel('Frequency/Hz');
xlabel('Time/s');
title('����ͼ');
axis([0 inf 0 1e4]);
%������ɫ
%m=64;
%LightYellow = [0.6 0.6 0.6];
%MidRed = [0 0 0];
%Black = [0.5 0.7 1];
%Colors = [LightYellow; MidRed; Black];
%colormap(SpecColorMap(m,Colors));%P41ҳ

%��֡���������λ
abs_yseg=abs(yseg);
angle_yseg = angle(yseg);

%the estimated direct sound hat_x
x'=zeros(size(y));
for i=1:fn_y
    

end