%%
clc; clear all; close all

mu=9e-7;
niter=150;
time = 2;
rev = num2str(time);
y_name = strcat('Audio\female3_rev',rev,'.wav');
z_name = strcat('Audio\female3_one',rev,'.wav');
xh_name = strcat('Audio\female3_two',rev,'.wav');

c = 342;                    % Sound velocity (m/s)
fs = 44100;                 %Sample rate
T = 1/fs;
%-----读取语音-----
%x是干净的，y是混响语音，z是第一阶段去混响的，xh是第二阶段后最终去混响的
[x,fs] = audioread('Audio/female3_clean.wav') ;
x=[x;0];%only for female3
[y,fs] = audioread(y_name) ;
y=[y;0];%only for female3
y=y/max(abs(y));
load h.mat
h=h(:,time*10-1);
%-----------
Nsig = size(x,1);
Lsig = Nsig/fs;
Nimp = size(h,1);
Limp = Nimp/fs;
nsig = 1:Nsig;
tsig = nsig/fs;
%------预增强------
%k = 0.97; %后面要LP就要预增强
%x_en=filter([1,-k],[1],x);
%y_en=filter([1,-k],[1],y);
%------分帧--------
%wlen = 0.02*fs; %每帧20ms
%inc = floor(0.3*wlen);%帧移
%overlap = wlen-inc;%重叠的部分
%xseg = enframe(x_en,hanning(wlen),inc)';
%yseg = enframe(y_en,hanning(wlen),inc)';
%fn = size(xseg,2);%帧数
%frameTime = frame2time(fn,wlen,inc,fs);

%LP残差
xr = lpres(x);
yr = lpres(y);

%残差的峰度
xkurt = kurtosis(xr,0,2);
ykurt = kurtosis(yr,0,2);
%lseg=400;
%theta=1e-6;

%xkurt=kurt(xr,lseg,theta);
%ykurt=kurt(yr,lseg,theta);

%残差的偏度
%xskew = skewness(xr,0,2); 
%yskew = skewness(yr,0,2); 

%%
%使峰度最大化的自适应逆滤波器

Lf=250;
%niter=150;
%mu=6e-7;
p=Lf;                       %filter order
ss=Lf/5;                      %stepsize
bs=ss+p-1;                  %blocksize
% gh=[1;zeros(p-1,1)];
gh=(1:p).';
gh=gh./sqrt(sum(abs(gh).^2));
Gh=fft([gh; zeros(ss-1,1)]);
zkurt=zeros(niter,1);

zr2=zeros(bs,1);
zr3=zeros(bs,1);
zr4=zeros(bs,1);

tic
for m=1:niter
    yrn=zeros(bs,1);
    for k=1:ss:Nsig
        yrn(1:p-1)=yrn(end-p+2:end);
        yrn(p:end)=yr(k:k+ss-1);
        
        Yrn=fft(yrn);
        cYrn=conj(Yrn);
        zrn=ifft(Gh.*Yrn);
        
        zrn(1:p-1)=0;
        zr2(p:end)=zrn(p:end).^2;
        zr3(p:end)=zrn(p:end).^3;
        zr4(p:end)=zrn(p:end).^4;
        
        Z2=sum(zr2(p:end));
        Z4=sum(zr4(p:end));
        
        zkurt(m)=max(zkurt(m),Z4/(Z2^2+1e-15)*ss);
        
        z3y=fft(zr3).*cYrn;
        zy=fft(zrn).*cYrn;

        gJ=4*(Z2*z3y-Z4*zy)/(Z2^3+1e-20)*ss;
        Gh=Gh+mu*gJ;
        
                
%         z3y=ifft(fft(zr3).*cYrn);
%         z3y(p+1:end)=0;
%         zy=ifft(fft(zrn).*cYrn);
%         zy(p+1:end)=0;
% 
%         gJ=4*(Z2*z3y-Z4*zy)/(Z2^3+1e-20)*ss;
%         Gh=Gh+mu*fft(gJ);
        
        
        Gh=Gh./sqrt(sum(abs(Gh).^2)/bs);
    end
end
toc

gh=ifft(Gh);%就是逆滤波器的系数了
% gh=gh(1:p);
%save female1_gh_0.3.mat gh

figure
plot(zkurt);
xlabel('Iterations'); ylabel('Maximum kurtosis');
%%

%load female1_gh_1.3.mat gh


figure
plot((1:Nimp),h); hold on
plot((1:Nimp),filter(gh,1,h), 'LineWidth',1)
xlabel('time(s)');title('Original vs Inverse filtered RIR');
legend('Original RIR', 'Inverse Filtered RIR');

%%
z=filter(gh, 1, y);%进行逆滤波
z=z/max(abs(z));%归一化
zr=lpres(z);%z的lp残差
zkurt = kurtosis(zr,0,2);
%zkurt=kurt(zr,lseg,theta);%z的残差峰度
%audiowrite('Audio\female1_one0.2.wav',z,fs);
%% 第二阶段
%wlen = 64e-3*fs;%64ms 一帧长度
wlen = 0.02*fs; %每帧20ms
%hop = 8e-3*fs;%8ms 每帧往后挪
hop = floor(0.3*wlen);%帧移
nfft = 1024;
[Sz, f_stft, t_stft] = stft(z, wlen, hop, nfft, fs);
Pz=abs(Sz).^2;
phz=angle(Sz);


ro_w=7;
a_w=5;
i_w=-ro_w:15;
wS=(i_w+a_w)/(a_w^2).*exp(-.5*(i_w/a_w+1).^2);%不对称光滑函数，作为瑞利分布
wS(i_w<-a_w)=0;
%figure;plot(i_w,wS)
%%
gS=.32;% scaling factor 
epS=1e-3;% 0.001
Pl=gS*filter(wS,1,Pz.').';%gS是衰减系数，wS是，Pz就是功率。谱减

P_att=(Pz-Pl)./Pz;
P_att(P_att<epS)=epS;

Pxh=Pz.*P_att;
Sxh=sqrt(Pxh).*exp(1i*phz);%相位？
%%
%静音帧处理
nu1=.05;
nu2=4;
Ez=sum(abs(Sz).^2, 1)/size(Sz,1);
Exh=sum(abs(Sxh).^2, 1)/size(Sxh,1);
P_att=ones(size(Sz,2),1);
P_att(Ez<nu1 & Ez./Exh>nu2)=1e-3;
Sxh=Sxh*spdiags(P_att,0,length(P_att),length(P_att));%spdiags提取所有非零对角线

[xh, t_istft] = istft(Sxh, wlen, hop, nfft, fs);
xh=xh/max(abs(xh));
xh=xh';
xh = [xh;zeros((size(x,1)-size(xh,1)),1)];
 %%
save female3_gh_2.mat gh
audiowrite(z_name,z,fs);
audiowrite(xh_name,xh,fs);
