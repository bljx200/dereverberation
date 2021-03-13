clear all;
Nfft=512;%F�任�ĵ���
[x,Fs] = audioread('origin_signal.wav');
N=size(x,1);
time=(0:N-1)/Fs;%�źŵ�ʱ�����꣨s��
x=x-mean(x);%����ֱ������
%w=0:N-1;
%---------------����Ԥ��ǿ-----------------
k = 0.97;%Ԥ��ǿϵ��

x1 = x;
for i = 2:size(x)
    x1(i) = x(i)-k*x(i-1);
end
%�� x1=filter([1,-k],[1],x);��ȫһ��
%---------------��֡�Ӵ�-----------------
wlen = 0.02*Fs;%ÿ֡�ĳ���
inc = 0.3*wlen;%֡��
overlap = wlen-inc;%�ص��Ĳ���
xseg = enframe(x1,hanning(wlen),inc)';
fn = size(xseg,2);%֡��
frameTime = frame2time(fn,wlen,inc,Fs);
%%
%��ʱ����ͼ(frameTime,En)
for i = 1:fn
u = xseg(:,i);%ȡ��һ֡
u2 = u.*u;%������
En(i) = sum(u2);%��һ֡�ۼ����
end

%plot(frameTime,En)
%%
%ƽ�����Ⱥ���
for i = 1:fn
u = xseg(:,i);%ȡ��һ֡
u2 = abs(u);%������
A(i) = sum(u2);%��һ֡�ۼ����
end
frameTime = frame2time(fn,wlen,inc,Fs);
%plot(frameTime,A)
%%
%��ʱƽ��������
for i=1:fn
    zcr(i) = sum(xseg(1:(end-1),i).*xseg(2:end,i)<0);
end
plot(frameTime,zcr);
%%
%��ʱ����غ���
R = zeros(wlen,fn);
for i=1:fn
   u = xseg(:,i);%ȡ����֡
   R_i = xcorr(u); %�������
   R_i = R_i(wlen:end);
   R(:,i)=R_i;
end