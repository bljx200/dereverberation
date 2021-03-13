clear all;
Nfft=512;%F变换的点数
[x,Fs] = audioread('origin_signal.wav');
N=size(x,1);
time=(0:N-1)/Fs;%信号的时间坐标（s）
x=x-mean(x);%消除直流分量
%w=0:N-1;
%---------------语音预增强-----------------
k = 0.97;%预增强系数

x1 = x;
for i = 2:size(x)
    x1(i) = x(i)-k*x(i-1);
end
%即 x1=filter([1,-k],[1],x);完全一样
%---------------分帧加窗-----------------
wlen = 0.02*Fs;%每帧的长度
inc = 0.3*wlen;%帧移
overlap = wlen-inc;%重叠的部分
xseg = enframe(x1,hanning(wlen),inc)';
fn = size(xseg,2);%帧数
frameTime = frame2time(fn,wlen,inc,Fs);
%%
%短时能量图(frameTime,En)
for i = 1:fn
u = xseg(:,i);%取出一帧
u2 = u.*u;%求能量
En(i) = sum(u2);%对一帧累加求和
end

%plot(frameTime,En)
%%
%平均幅度函数
for i = 1:fn
u = xseg(:,i);%取出一帧
u2 = abs(u);%求能量
A(i) = sum(u2);%对一帧累加求和
end
frameTime = frame2time(fn,wlen,inc,Fs);
%plot(frameTime,A)
%%
%短时平均过零率
for i=1:fn
    zcr(i) = sum(xseg(1:(end-1),i).*xseg(2:end,i)<0);
end
plot(frameTime,zcr);
%%
%短时自相关函数
R = zeros(wlen,fn);
for i=1:fn
   u = xseg(:,i);%取出这帧
   R_i = xcorr(u); %求自相关
   R_i = R_i(wlen:end);
   R(:,i)=R_i;
end