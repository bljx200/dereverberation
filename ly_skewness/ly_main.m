%%
clc; clear all; close all
 for a=2:20
    time=a/10;
%time = 0.2;
mu=1e-6;
niter=150;
%time = 0.6;
rev = num2str(time);
y_name = strcat('Audio\male3_rev',rev,'.wav');
z_name = strcat('Audio\male3_one',rev,'.wav');
xh_name = strcat('Audio\male3_two',rev,'.wav');
f1_name = strcat('male3_',rev,'s_iteration.jpg');
f2_name = strcat('male3_',rev,'filtered_RIR.jpg');

c = 342;                    % Sound velocity (m/s)
fs = 44100;                 %Sample rate
T = 1/fs;
%-----��ȡ����-----
%x�Ǹɾ��ģ�y�ǻ���������z�ǵ�һ�׶�ȥ����ģ�xh�ǵڶ��׶κ�����ȥ�����
[x,fs] = audioread('Audio/male3_clean.wav') ;
% x=[x;0];%only for female3
[y,fs] = audioread(y_name) ;
%  y=[y;0];%only for female3
%------Ԥ��ǿ------
k = 0.97;
y=filter([1,-k],[1],y);
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

%------��֡--------
%wlen = 0.02*fs; %ÿ֡20ms
%inc = floor(0.3*wlen);%֡��
%overlap = wlen-inc;%�ص��Ĳ���
%xseg = enframe(x_en,hanning(wlen),inc)';
%yseg = enframe(y_en,hanning(wlen),inc)';
%fn = size(xseg,2);%֡��
%frameTime = frame2time(fn,wlen,inc,fs);

%LP�в�
xr = lpres(x);
yr = lpres(y);

%�в�ķ��
%xkurt = kurtosis(xr,0,2);
%ykurt = kurtosis(yr,0,2);

%xkurt=kurt(xr,lseg,theta);
%ykurt=kurt(yr,lseg,theta);

%�в��ƫ��
lseg=400;
theta=1e-6;
xkurt=skew(xr,lseg,theta);
ykurt=skew(yr,lseg,theta);
% xskew = skewness(xr,0,2); 
% yskew = skewness(yr,0,2); 

%%
%ʹ�����󻯵�����Ӧ���˲���

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
zskew=zeros(niter,1);

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
        Z3=sum(zr3(p:end));
        Z4=sum(zr4(p:end));
        
      % zskew(m)=max(zskew(m),Z3/(Z2^(3/2)+1e-15)*ss);
        zskew(m)=max(zskew(m),Z3/(Z2^(3/2))*ss);
        zy=fft(zrn).*cYrn;
        z2y=fft(zr2).*cYrn;
        z3y=fft(zr3).*cYrn;
        
      % gJ=4*(Z2*z3y-Z4*zy)/(Z2^3+1e-20)*ss;%��ȵ��ݶ�
        gJ=3*(Z2*z2y-Z3*zy)/(Z2^(5/2))*ss;%ƫ�ȵ��ݶ�
        Gh=Gh+mu*gJ;
        Gh=Gh./sqrt(sum(abs(Gh).^2)/bs);
    end
end
toc

gh=ifft(Gh);%�������˲�����ϵ����
% gh=gh(1:p);
%save female1_gh_0.3.mat gh

figure
plot(zskew);
xlabel('Iterations'); ylabel('Maximum skewness');
print(f1_name,'-djpeg','-r600');
%%

%load female1_gh_1.3.mat gh


figure
plot((1:Nimp),h); hold on
plot((1:Nimp),filter(gh,1,h), 'LineWidth',1)
xlabel('time(s)');title('Original vs Inverse filtered RIR');
legend('Original RIR', 'Inverse Filtered RIR');
print(f2_name,'-djpeg','-r600');
%%
z=filter(gh, 1, y);%�������˲�
z=z/max(abs(z));%��һ��
zr=lpres(z);%z��lp�в�
zskew = skewness(zr,0,2); 
%zkurt=kurt(zr,lseg,theta);%z�Ĳв���
%% �ڶ��׶�
%wlen = 64e-3*fs;%64ms һ֡����
wlen = 0.02*fs; %ÿ֡20ms
%hop = 8e-3*fs;%8ms ÿ֡����Ų
hop = floor(0.3*wlen);%֡��
nfft = 1024;
[Sz, f_stft, t_stft] = stft(z, wlen, hop, nfft, fs);
Pz=abs(Sz).^2;
phz=angle(Sz);

ro_w=7;
a_w=5;
i_w=-ro_w:15;
wS=(i_w+a_w)/(a_w^2).*exp(-.5*(i_w/a_w+1).^2);%���Գƹ⻬��������Ϊ�����ֲ�
wS(i_w<-a_w)=0;
%figure;plot(i_w,wS)
%%
gS=.32;% scaling factor 
epS=1e-3;% 0.001
Pl=gS*filter(wS,1,Pz.').';%gS��˥��ϵ����wS�ǣ�Pz���ǹ��ʡ��׼�

P_att=(Pz-Pl)./Pz;
P_att(P_att<epS)=epS;

Pxh=Pz.*P_att;
Sxh=sqrt(Pxh).*exp(1i*phz);%��λ��
%%
%����֡����
nu1=.05;
nu2=4;
Ez=sum(abs(Sz).^2, 1)/size(Sz,1);
Exh=sum(abs(Sxh).^2, 1)/size(Sxh,1);
P_att=ones(size(Sz,2),1);
P_att(Ez<nu1 & Ez./Exh>nu2)=1e-3;
Sxh=Sxh*spdiags(P_att,0,length(P_att),length(P_att));%spdiags��ȡ���з���Խ���

[xh, t_istft] = istft(Sxh, wlen, hop, nfft, fs);
xh=xh/max(abs(xh));
xh=xh';
xh = [xh;zeros((size(x,1)-size(xh,1)),1)];
 %%
    gh_name=strcat('male3_gh',rev,'.mat');
    save(gh_name,'gh');
%save female1_gh_0.6.mat gh
audiowrite(z_name,z,fs);
audiowrite(xh_name,xh,fs);
 end
 rmpath('./YAPPT');
 rmpath('./BaNa');