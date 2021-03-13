clc; clear all; close all;
%for a=2:20
%      time=a/10;
%      rev = num2str(time);
 y_name = strcat('Audio\female1_rev1.wav');
    
[y,fs]=audioread(y_name);
% t=(0:length(y)-1)/(fs);  % time in msec;
%%
%YAAPT
ExtrPrm.fft_length = 8192; 
ExtrPrm.f0_min = 100;        % Change minimum F0 searched to 60Hz
ExtrPrm.f0_max = 400; 
ExtrPrm.frame_length = 25;
 [f0_YAAPT, nf, frmrate] = yaapt(y, fs, 1,ExtrPrm, 0,1);
%%
%BANA
timestep=0.01;
f0_BANA = Bana_auto(y, fs, ExtrPrm.f0_min, ExtrPrm.f0_max, timestep, 1.7);
f0_BANA = [f0_BANA;0;0;0]';
%% FFT specs for plots
fft_length = 8192;
frame_size = 25*fs/1000;    
frame_jump = 5*fs/1000;

startf     =  20;                  % starting frequency for spectral plots
finalf     =  500;
startt = 1/fs;
finalt = length(y)/fs;

N_startf = round((startf/fs) * fft_length+1);
N_finalf = round((finalf/fs) * fft_length+1); % add +1 6/3/13

Spec_mag = abs(specgram(y,fft_length,fs,frame_size,frame_size-frame_jump));
Spec_log = log(Spec_mag + eps);
Spec_log = Spec_log(N_startf:N_finalf,:);
[nrow,ncol] =  size(Spec_log);
tt_spec     =  linspace(startt, finalt, ncol); % X axis
ff_spec     =  linspace(startf, finalf, nrow);  % Y axis

%%
figure
k=3;
ax(1)=subplot(k,1,1);
plot((0:length(y)-1),y/max(abs(y)))
% title_name = strcat('male3-rev',rev,'s');
title('female1 rev1');
text(1.01,0.6,'(a)','Units', 'Normalized', 'VerticalAlignment', 'Top')

ax(2)=subplot(k,1,2);
imagesc(tt_spec,ff_spec,Spec_log);
colormap(jet);
axis([startt finalt startf finalf]);
axis xy;
hold on
%n=0:size(f0_YAAPT,1)-1;
n = f0_YAAPT;
n(1:(end-2)) = downsample(tt_spec, 2);
plot(n,f0_YAAPT,'.k')
hold off
xlabel('Spectrum')
text(1.01,0.6,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top')
ylabel('Hz')
title('YAAPT f0 Estimation');

ax(3)=subplot(k,1,3);
imagesc(tt_spec,ff_spec,Spec_log);
colormap(jet);
axis([startt finalt startf finalf]);
axis xy;
hold on
plot(n,f0_BANA,'.k')
hold off
xlabel('Spectrum')
text(1.01,0.6,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top')
ylabel('Hz')
title('BANA f0 Estimation');

% f2_name = strcat('fig\f0_male3_rev',rev,'.jpg');
% print(f2_name,'-djpeg','-r600');
%end