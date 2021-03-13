function [SNRI,SNRO,segSNRI,segSNRO,LSDI,LSDO]=res_eva(spe,noisy,eha,fs,frame,fstep)
% res_eva result evaluation ������ۣ���������ȣ��ֶ�����ȣ�LSD��log-spectral
% distortion�����������ƴ���segERR
%
%���룺spe ���������ź� noi ���������ź� eha ��ǿ�������ź� ��noisy��
%      frame ���ڳ��ȣ�fstep �ƶ�����
%�����   SNRI��SNRO        ������������
%      segSNRI��segSNRI     ��������ֶ������
%         LSDI��LSDO        �������LSD
%         LSD2I��LSD2O      �㷨2�����LSD�� Frames are 25ms long with 60 percent
%                           (15ms) overlap�����ĸ�������ʾ�Ƿ�ȥ�������Σ�0��ȥ��1ȥ
%         PESQ_I PESQ_O      ���������PESQ
%�汾���Ȩ��
%        res_eva v1.0  2010-11-07   ԭ��
%        res_eva v2.0  2011-01-07  ��1�������PESQ����2�������LSD2����Ϊ�ο�
%               Copyright (c) 2010. Infocarrier.
%               All rights reserved. 
%% ��������������
%le=length(eha);
%spe=spe(1:le);
%noi=noi(1:le);
noi = noisy - spe;
%noisy=noi+spe;
%% �����,SNRI ��������ȣ�SNRO ��������
SNR1=mean(spe.^2)/mean(noi.^2);
SNRI=10*log10(SNR1);

SNR1=mean(spe.^2)/mean((spe-eha).^2);
SNRO=10*log10(SNR1);

%% �ֶ������ segSNR��segSNRI ����ֶ�����ȣ�SNRO ����ֶ������
N=frame;
M=fstep;
le=length(eha);
ss=fix(le/fstep); 
ts=ss-3;
SNRt=zeros(1,ss);
for t=1:ts
    SNRt(t)=10*log10(sum(spe((t-1)*M+1:(t-1)*M+N).^2)/sum(noi((t-1)*M+1:(t-1)*M+N).^2));
end
SNRtp=min(max(SNRt,-10),35);
segSNRI=sum(SNRtp)/ts;

for t=1:ts
    SNRt(t)=10*log10(sum(spe((t-1)*M+1:(t-1)*M+N).^2)/...
sum((spe((t-1)*M+1:(t-1)*M+N)-eha((t-1)*M+1:(t-1)*M+N)).^2));% ��ʽ44.95,96
end
SNRtp=min(max(SNRt,-10),35);
segSNRO=sum(SNRtp)/ts;

%% LSD

%%%��������
speX=spectrogram(spe,frame,frame-fstep,frame);
speX=20*log10(abs(speX));%speX(K,T),����ʱ����
theta=max(max(speX))-50;
LspeX=max(speX,theta);
%%%��������
noisY=spectrogram(noisy,frame,frame-fstep,frame);
noisY=20*log10(abs(noisY));
thetaY=max(max(noisY))-50;
LnoisY=max(noisY,thetaY);
%%%��ǿ������
speX1=spectrogram(eha,frame,frame-fstep,frame);
speX1=20*log10(abs(speX1));
theta1=max(max(speX1))-50;
LspeX1=max(speX1,theta1);
%%% ����LSD
LnoisY(1,:)=0;
LspeX(1,:)=0;
LspeX1(1,:)=0;%����Ҷϵ���ĵ�һ��DC�����㣬��ʽû���õ�
LSDI=(1/ts)*sum((2/N*sum((LnoisY-LspeX).^2)).^(1/2));
%%%�������LSD
LSDO=(1/ts)*sum((2/N*sum((LspeX-LspeX1).^2)).^(1/2));
%% LSD2
% LSD2I=LogSpectralDistance(spe,noisy,fs,0);%���ĸ�������0��ȥ�������Σ�1ȥ��������
% LSD2O=LogSpectralDistance(spe,eha,fs,0);%���ĸ�������0��ȥ�������Σ�1ȥ��������
%% PESQ
%%% [pesq_mos]=pesq(sfreq,cleanfile.wav,enhanced.wav) 
%addpath('eva_composite');
%fname_noisy='temp_noisy.wav';
%fname_spe='temp_spe.wav';
%fname_eha='temp_eha.wav';
%wavwrite(noisy,fs,fname_noisy);
%wavwrite(spe,fs,fname_spe);
%wavwrite(eha,fs,fname_eha);
%PESQ_I=pesq(fs,fname_spe,fname_noisy); 
%PESQ_O=pesq(fs,fname_spe,fname_eha); 
%delete(fname_noisy);
%delete(fname_spe);
%delete(fname_eha);


