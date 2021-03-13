% Plot ground truth F0 values for one wave file. F0 ground truth
% values are calculated by averaging the detected F0 values of three
% algorithms: BaNa, YIN and Praat. If the detected F0 values deviate
% more than error_tolerance (10%), the frame is considered to be unvoiced.
% 
% See the Bridge project website at Wireless Communication and Networking
% Group (WCNG), University of Rochester for more information:
% http://www.ece.rochester.edu/projects/wcng/project_bridge.html
%
% Written by He Ba, Na Yang, and Weiyang Cai, University of Rochester.
% Copyright (c) 2013 University of Rochester.
% Version August 2013.
%
% Permission to use, copy, modify, and distribute this software without
% fee is hereby granted FOR RESEARCH PURPOSES only, provided that this
% copyright notice appears in all copies and in all supporting
% documentation, and that the software is not redistributed for any fee.
%
% For any other uses of this software, in original or modified form,
% including but not limited to consulting, production or distribution
% in whole or in part, specific prior permission must be obtained from WCNG.
% Algorithms implemented by this software may be claimed by patents owned
% by WCNG, University of Rochester.
%
% The WCNG makes no representations about the suitability of this
% software for any purpose. It is provided "as is" without express
% or implied warranty.
%

clear all;
close all;

addpath('../BaNa F0 detection algorithm','../Other F0 detection algorithms'); % add source code for BaNa and YIN

f0min = 50;
f0max = 600;
timestep = 0.01;
time_per_window = 0.06;
error_tolerance = 0.1;

filename = 'Audio files/Clean speech/LDC/cc_001m_happy_14.wav';
[y,fs] = wavread(filename);
advance_len = ceil(timestep*fs);
frame_len = ceil(time_per_window*fs); % number of samples per frame
frame_num = floor((length(y)-frame_len)/advance_len)+1; % number of frames

% BaNa
f0_bana =  Bana(y,fs,f0min,f0max,timestep,ones(1,frame_num));

% YIN
R = YIN(filename); % output R is a structure
len_yin = length(R.f0); % real frame num for YIN
f0_yin = zeros(len_yin,1);
for myp = 1: len_yin
    f0_yin(myp,1) = 440*(2^R.f0(myp)); % convert YIN's original output F0 from 440Hz octave to Hz
end    
% Due to the different hop length, need to choose YIN's frames
% with the centers match BaNa's frame centers
f0_yin_match = zeros(frame_num,1); % initialize f0_yin with matched frames        
hop1 = ceil(advance_len); % hop length of BaNa
framectr1 = ceil(frame_len/2); % the sample index of the center of BaNa's first frame
hop2 = R.hop; % default hop length of YIN
framectr2 = ceil(R.wsize/2); % the sample index of the center of YIN's first frame
for fn = 1:frame_num
    sample_no = framectr1+(fn-1)*hop1; % center to be matched
    frame_yin_larger = floor((sample_no-framectr2)/hop2)+1;
    frame_yin_smaller = ceil((sample_no-framectr2)/hop2)+1;
    sample_cand_larger = framectr2+hop2*(frame_yin_larger-1);
    sample_cand_smaller = framectr2+hop2*(frame_yin_smaller-1);
    if abs(sample_cand_larger-sample_no)>abs(sample_cand_smaller-sample_no)
       frame_yin = frame_yin_smaller;
    else
        frame_yin = frame_yin_larger;
    end
    f0_yin_match(fn)=f0_yin(frame_yin);
end
f0_yin_match(f0_yin_match ==0) = NaN;   

% Praat
textname = 'Praat detected F0/Speech/LDC/cc_001m_happy_14.txt';
fid = fopen(textname);
C = textscan(fid,'%f %f');
C{1} ={0.01;0.02;C{1}};
C{2} ={0.0000;0.0000;C{2}};
m1 = cell2mat(C{1});
m1 = round(100*m1)/100;
m2 = cell2mat(C{2});
m2 = round(100*m2)/100;
fclose(fid);
l1 = length(m1);
f0_praat = zeros(1,frame_num);
for i = 1:l1
    if int32(m1(i)*100)<=frame_num
        f0_praat(int32(m1(i)*100)) = m2(i);
    end
end
f0_praat(f0_praat == 0) = NaN;

% calculate ground truth
gt = zeros(1,frame_num);
for i = 1:frame_num
    if max([f0_bana(i),f0_yin_match(i),f0_praat(i)])-min([f0_bana(i),f0_yin_match(i),f0_praat(i)]) > error_tolerance*min([f0_bana(i),f0_yin_match(i),f0_praat(i)])
        gt(i) = NaN;
    else
        gt(i) = mean([f0_bana(i),f0_yin_match(i),f0_praat(i)]);
    end
end


% plot waveform, spectrogram, and ground truth
fig1 = figure;
n = 0:1/fs:(length(y)-1)/fs;
subplot(2,1,1);
plot(n,y);
axis([0 1 -0.4 0.4]);
h1 = xlabel('Time (s)');
h2 = ylabel('Amplitude');
set(h1,'fontsize',14);
set(h2,'fontsize',14);
set(gca,'fontsize',14);
legend('waveform');

subplot(2,1,2);
hold on;
n1 = 0:timestep:(frame_num-1)* timestep;
plot(n1,f0_bana,'bd')
plot(n1,f0_yin_match,'ro')
plot(n1,f0_praat,'gs')
plot(n1,gt,'k.')
h3 = xlabel('Time (s)');
h4 = ylabel('Detected F0 (Hz)');
set(h3,'fontsize',14);
set(h4,'fontsize',14);
set(gca,'fontsize',14);
ylim([0 300]);
legend('BaNa', 'YIN','Praat','Ground Truth');
box on;

% plot spectrogram
fig2 = figure;
spectrogram(y,frame_len, frame_len-advance_len, 2^16, fs);
xlim([0 700]);
