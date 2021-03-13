% F0 detection algorithms evaluation for music
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

close all; 
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   add external files to path
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../BaNa F0 detection algorithm',genpath('../Other F0 detection algorithms')); % add source code for other F0 detection algorithms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Parameter settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_per_window = 0.06; % frame length in second
f0max = 4000; % higher bound of music F0
f0min = 50; % lower bound of music F0
timestep = 0.01; % time step of detected F0 (second)
error_tolerance = 0.03; % error tolerance for F0 detection on music is 3% (music quater tone), detected F0 deviates more than error_tolerance from ground truth F0 is counted as an error.
pthr1 = 1.1; % amplitude ratio of the two highest Cepstrum peaks, used for music/not music detection for Cepstrum F0 detection.
SNR_dB1 = [0 5 10 15 20]; % SNR levels
noise_type1 = {'babble','destroyerengine','destroyerops','factory','hfchannel','pink','volvo','white'};
instrument = 'violin'; % options: 'violin', 'trumpet', 'clarinet', 'piano'.

groundtruth_path = 'Ground truth/music/';
noisyfile_path = ['Audio files/Noisy music/Noisy ' instrument '/'];
Praat_dir = ['Praat detected F0/Music/' instrument '/'];

% save workspace with timestamp
date_now = clock;
date_now = strcat(num2str(date_now(1)), num2str(date_now(2)), num2str(date_now(3)), '-', num2str(date_now(4)), num2str(date_now(5)));
saveFilename = ['Saved workspace/' instrument '-' date_now '.mat'];


% initialization
load([groundtruth_path instrument '.mat']); % F0 ground truth in MAT file
vm = zeros(1,length(gt)); % initialize the music marker. 1: music frame, 0: not music frame
vm(gt~=0)=1; % in groundtruth, not music frames are labeled as 0
len = sum(vm);
num_noise= length(noise_type1);
num_SNR = length(SNR_dB1);

% initilize the average rate matrix for all files in a list
rate_bana = zeros(num_noise,num_SNR);
rate_hps = zeros(num_noise,num_SNR);
rate_yin = zeros(num_noise,num_SNR);
rate_cep = zeros(num_noise,num_SNR);
rate_praat = zeros(num_noise,num_SNR);

for j = 1:num_noise
    for k =1:num_SNR
        noisy_file = [instrument,'-',char(noise_type1{j}),'_',num2str(SNR_dB1(k)),'dB'];
        noisyfilename = [noisyfile_path noisy_file '.wav']; 
        [y,fs] = wavread(noisyfilename);
        frame_len = ceil(time_per_window*fs);
        advance_len = ceil(timestep*fs);
        frame_num = floor((length(y)-frame_len)/advance_len)+1; % number of frames
        
        % BaNa
        f0_bana= Bana_music(y,fs,f0min,f0max,timestep,vm);
        er = abs(f0_bana - gt'); % difference between ground truth and the detected F0
        hit = zeros(1,frame_num);
        for i = 1:frame_num
            if er(i)< error_tolerance*gt(i) && vm(i) == 1 
                hit(i) = 1;
            end
        end
        rate_bana(j,k) = sum(hit)/len;
        
        % Cepstrum
        [f0_cep,~] = cepstral(y, fs, f0min, f0max, timestep, pthr1);
        er = abs(f0_cep' - gt); % difference between ground truth and the detected F0
        hit = zeros(1,length(gt));
        for i = 1:frame_num
            if er(i)< error_tolerance*gt(i) && vm(i) == 1
                hit(i) = 1;
            end
        end
        rate_cep(j,k) = sum(hit)/len;
        
        % YIN
        R = YIN(noisyfilename); % output R is a structure
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
        er = abs(f0_yin_match - gt'); % difference between ground truth and the detected F0
        hit = zeros(1,frame_num);
        for i = 1:frame_num
            if er(i)<= error_tolerance*gt(i) && vm(i) == 1 
                hit(i) = 1;
            end
        end
        rate_yin(j,k) = sum(hit)/len;    
        
        % HPS
        f0_hps = zeros(1,frame_num);
        for i = 1:frame_num
            temp = y(((i-1)*advance_len+1):((i-1)*advance_len+frame_len));
            f0_hps(i) = hps(temp,fs);
        end
        er = abs(f0_hps - gt); % difference between ground truth and the detected F0
        hit = zeros(1,frame_num);
        for i = 1:frame_num
            if er(i)< error_tolerance*gt(i) && vm(i) == 1
                hit(i) = 1;
            end
        end
        rate_hps(j,k) = sum(hit)/len;  
        
        % Praat
        textname = strcat([Praat_dir noisy_file '.txt']);
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
            if int32(m1(i)*1/timestep)<=frame_num
                f0_praat(int32(m1(i)*1/timestep)) = m2(i);
            end
        end
        er = abs(f0_praat - gt); % difference between ground truth and the detected F0
        hit = zeros(1,frame_num);
        for i = 1:frame_num
            if er(i)<= error_tolerance*gt(i) && vm(i) == 1
                hit(i) = 1;
            end
        end
        rate_praat(j,k) = sum(hit)/len;     
        
        
        % F0 detection of one wave file is finished for all
        % algorithms
        disp(['F0 detection for file ', noisy_file, ' has finished.']);
    end
end

% average over all types of noise
rate_bana_av = mean(rate_bana);
rate_cep_av = mean(rate_cep);
rate_hps_av = mean(rate_hps);
rate_yin_av = mean(rate_yin);
rate_praat_av = mean(rate_praat);

% Gross Pitch Error (GPE) rate
GPE_bana = 1-rate_bana_av;
GPE_cep = 1-rate_cep_av;
GPE_hps = 1-rate_hps_av;
GPE_yin = 1-rate_yin_av;
GPE_praat = 1-rate_praat_av;

% save data
save(saveFilename);

% plot GPE rates vs. SNR for all algorithms averaged over 8 types of noise
% and 5 noise levels
fig1 = figure;
hold on;
linestyles = cellstr(char('--r','-k','-g','-b','-c'));
markers=['s','d','>','*','x'];
plot(SNR_dB1,GPE_bana*100,[linestyles{1} markers(1)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_hps*100,[linestyles{2} markers(2)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_yin*100,[linestyles{3} markers(3)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_praat*100,[linestyles{4} markers(4)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_cep*100,[linestyles{5} markers(5)],'LineWidth',2,'MarkerSize',10);
legend('BaNa','HPS','YIN','Praat','Cepstrum','Location','NorthEast');
h1 = xlabel('SNR (dB)'); 
h2 = ylabel('Gross Pitch Error Rate (GPE)(%)');
set(h1,'fontsize',14);
set(h2,'fontsize',14);
set(gca,'fontsize',14,'XTick',SNR_dB1);
ylim([0 100]);
set(fig1,'WindowStyle','normal');  
set(fig1,'Position',[50 50 650 500]);
grid on;

% plot GPE rates of BaNa vs. YIN vs. HPS with 0dB SNR for all 8 types of noise (bar graph)
fig2 = figure;
dBindex = find(SNR_dB1==0);
plot_data = [1-rate_bana(:,dBindex) 1-rate_yin(:,dBindex) 1-rate_hps(:,dBindex)];
bar(plot_data*100,'group')
set(gca,'XTickLabel',{'babble', 'engine', 'operation', 'factory', 'highfreq', 'pink', 'vehicle', 'white'})
legend('BaNa', 'YIN', 'HPS','Location','NorthEast');
h1 = xlabel('Type of noise'); h2 = ylabel('Gross Pitch Error Rate (GPE)(%)'); 
set(h1,'fontsize',14);
set(h2,'fontsize',14); 
set(gca,'fontsize',12);
set(gca,'YGrid','on');
