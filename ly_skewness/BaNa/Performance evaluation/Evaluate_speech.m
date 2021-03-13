% F0 detection algorithms evaluation for speech
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
f0max = 600; % higher bound of human speech F0
f0min = 50; % lower bound of human speech F0
timestep = 0.01; % time step of detected F0 (second)
error_tolerance = 0.1; % error tolerance for F0 detection on speech, detected F0 deviates more than error_tolerance from ground truth F0 is counted as an error.
pthr1 = 1.1; % amplitude ratio of the two highest Cepstrum peaks, used for voiced/unvoiced detection for Cepstrum F0 detection.
gt_shift = 0; % number of F0 values to be shifted in the ground truth file. Additional zeros might exist at the beginning and the end of the ground truth file
% set gt_shift to 2 for CSTR, 3 for KEELE, and 0 for other databases
SNR_dB1 = [0 5 10 15 20]; % SNR levels
noise_type1 = {'babble','destroyerengine','destroyerops','factory','hfchannel','pink','volvo','white'};
DBname = 'LDC'; % database name. Options: 'LDC', 'Arctic', 'CSTR', 'KEELE'.

cleanFiles_dir = ['Audio files/Clean speech/' DBname '/'];
groundtruth_path = ['Ground truth/Speech/' DBname '/gt_'];
Praat_dir = ['Praat detected F0/Speech/' DBname '/'];
noisyfile_path = ['Audio files/Noisy speech/Noisy ' DBname '/'];

% save workspace with timestamp
date_now = clock;
date_now = strcat(num2str(date_now(1)), num2str(date_now(2)), num2str(date_now(3)), '-', num2str(date_now(4)), num2str(date_now(5))); % date and time 
saveFilename = ['Saved workspace/' DBname '-' date_now '.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   F0 evaluation starts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialization
num_noise = length(noise_type1);
num_SNR = length(SNR_dB1);

% initilize the average rate matrix for all files in a list
rate_bana_av_all1 = zeros(1, num_SNR);
rate_hps_av_all1 = zeros(1, num_SNR);
rate_yin_av_all1 = zeros(1, num_SNR);
rate_praat_av_all1 = zeros(1, num_SNR);
rate_cep_av_all1 = zeros(1, num_SNR);
rate_pefac_av_all1 = zeros(1, num_SNR);

% initilize the average rate matrix for all SNR values for all files
rate_bana_av_dB = zeros(num_noise, num_SNR);
rate_hps_av_dB = zeros(num_noise, num_SNR);
rate_yin_av_dB = zeros(num_noise, num_SNR);
rate_praat_av_dB = zeros(num_noise, num_SNR);
rate_cep_av_dB = zeros(num_noise, num_SNR);
rate_pefac_av_dB = zeros(num_noise, num_SNR);

files = dir(fullfile(cleanFiles_dir,'*.wav'));
num_list = length(files);
for filenum = 1:num_list
    cleanfilename = files(filenum).name;
    [~,nm]= fileparts(cleanfilename); % nm: clean filename without extension
    filenamefull = strcat([cleanFiles_dir nm '.wav']);
    gtname = strcat(groundtruth_path, nm, '.mat'); % ground truth MAT file name
    load(gtname);
    if strcmp(DBname, 'CSTR')==1
        gt = y2;
    end
    if size(gt,1)<size(gt,2)
        gt=gt';
    end
    
    % initialize the rate matrix for one audio file
    rate_bana = zeros(num_noise,num_SNR);
    rate_cep = zeros(num_noise,num_SNR);
    rate_hps = zeros(num_noise,num_SNR);
    rate_yin = zeros(num_noise,num_SNR);
    rate_praat = zeros(num_noise,num_SNR);
    rate_pefac = zeros(num_noise,num_SNR);
    
    for j = 1:num_noise
        for k =1:num_SNR
            noisy_file = [nm,'-',noise_type1{j},'_',num2str(SNR_dB1(k)),'dB'];
            noisyfilename = [noisyfile_path, noisy_file,'.wav'];
            [y,fs] = wavread(noisyfilename); % read wave file
            frame_len = ceil(time_per_window*fs);
            advance_len = ceil(timestep*fs);
            frame_num = floor((length(y)-frame_len)/advance_len)+1; % number of frames
            m = min(frame_num+gt_shift, length(gt));
            gt_adjusted = gt(1+gt_shift:m); % KEELE and CSTR's ground truth might not be of the same length with frame_num
            len = length(gt_adjusted);
            vm = zeros(1,len);
            vm(gt_adjusted>0) = 1; % voice marker
            voiced_num = nnz(vm); % number of voiced frames
            
            % padding zeros at the end of voice marker if vm is shorter
            % than frame_num
            if len<frame_num
                vm_long = [vm zeros(1,frame_num-len)];
            else
                vm_long = vm;
            end
            
            % BaNa
            f0_bana = Bana(y,fs,f0min,f0max,timestep,vm_long);
            er = abs(f0_bana(1:len) - gt_adjusted); % difference between ground truth and the detected F0
            hit = zeros(1,len);
            for i = 1:len
                if er(i)<= error_tolerance*gt_adjusted(i) && vm(i) == 1 
                    hit(i) = 1;
                end
            end
            rate_bana(j,k) = sum(hit)/voiced_num;
            
            % Cepstrum
            [f0_cep,~] = cepstral(y, fs, f0min, f0max, timestep, pthr1);
            er = abs(f0_cep(1:len) - gt_adjusted); % difference between ground truth and the detected F0
            hit = zeros(1,len);
            for i = 1:len
                if er(i)<= error_tolerance*gt_adjusted(i) && vm(i) == 1
                    hit(i) = 1;
                end
            end
            rate_cep(j,k) = sum(hit)/voiced_num;
            
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
            er = abs(f0_yin_match(1:len) - gt_adjusted); % difference between ground truth and the detected F0
            hit = zeros(1,len);
            for i = 1:len
                if er(i)<= error_tolerance*gt_adjusted(i) && vm(i) == 1 
                    hit(i) = 1;
                end
            end
            rate_yin(j,k) = sum(hit)/voiced_num;         
            
            % HPS
            f0_hps = zeros(frame_num,1);
            for i = 1:frame_num
                temp = y(((i-1)*advance_len+1):((i-1)*advance_len+frame_len));
                f0_hps(i) = hps(temp,fs);
            end
            er = abs(f0_hps(1:len) - gt_adjusted); % difference between ground truth and the detected F0
            hit = zeros(1,len);
            for i = 1:len
                if er(i)<= error_tolerance*gt_adjusted(i) && vm(i) == 1 
                    hit(i) = 1;
                end
            end
            rate_hps(j,k) = sum(hit)/voiced_num;  
            
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
            f0_praat = zeros(frame_num,1);
            for i = 1:l1
                if int32(m1(i)*1/timestep)<=frame_num
                    f0_praat(int32(m1(i)*1/timestep)) = m2(i);
                end
            end
            er = abs(f0_praat(1:len) - gt_adjusted); % difference between ground truth and the detected F0
            hit = zeros(1,len);
            for i = 1:len
                if er(i)<= error_tolerance*gt_adjusted(i) && vm(i) == 1
                    hit(i) = 1;
                end
            end
            rate_praat(j,k) = sum(hit)/voiced_num;   
            
            % PEFAC
            % The first detected F0 of PEFAC is at 45 ms (half of the 
            % default frame length: 90ms), while the first ground truth 
            % F0 value is at 30 ms. Thus we need to delete the samples 
            % within the first 5 ms of the audio when detecingt F0 using
            % PEFAC, in order to detect F0 from the frame centered at
            % 50 ms for both the ground truth and PEFAC.  
            % Values need to be modified if frame length or timestep is
            % changed
            pefac_shift = round(0.005*fs); % number of samples deleted at the beginning
            [f0_pefac,~,~,~]=fxpefac(y(pefac_shift+1:end),fs);
            % start comparing with ground truth from 50ms, thus delete the 
            % first two ground truth values
            gt_adjusted1 = gt_adjusted(3:end);
            % f0_pefac should be of the same length of the F0 ground 
            % truth. Choose whichever is smaller
            if length(gt_adjusted1)>length(f0_pefac)
                gt_adjusted1 = gt_adjusted1(1:length(f0_pefac));
            else
                f0_pefac = f0_pefac(1:length(gt_adjusted1));
            end
            er = abs(f0_pefac - gt_adjusted1); % difference between ground truth and the detected F0
            len1 = length(gt_adjusted1);
            hit = zeros(1,len1);
            for i = 1:len1
                if er(i)<= error_tolerance*gt_adjusted1(i) && gt_adjusted1(i)>0 
                    hit(i) = 1;
                end
            end
            vm1 = zeros(1,len1); % initialize the voice marker. 1: voiced frame, 0: unvoiced frame
            vm1(gt_adjusted1>0)=1; % in groundtruth, unvoiced frames are labeled as 0 or smaller than 0
            voiced_num1 = nnz(vm1); % number of voiced frames
            rate_pefac(j,k) = sum(hit)/voiced_num1;
            
            
            % F0 detection of one wave file is finished for all
            % algorithms
            disp(['F0 detection for file ', noisy_file, ' has finished.']);
        end
    end
    
    rate_bana_av = mean(rate_bana);
    rate_cep_av = mean(rate_cep);
    rate_hps_av = mean(rate_hps);
    rate_yin_av = mean(rate_yin);
    rate_praat_av = mean(rate_praat);
    rate_pefac_av = mean(rate_pefac);
    
    rate_bana_av_all1 = rate_bana_av_all1 + rate_bana_av;
    rate_hps_av_all1 = rate_hps_av_all1 + rate_hps_av;
    rate_yin_av_all1 = rate_yin_av_all1 + rate_yin_av;
    rate_cep_av_all1 = rate_cep_av_all1 + rate_cep_av;
    rate_praat_av_all1 = rate_praat_av_all1 + rate_praat_av;
    rate_pefac_av_all1 = rate_pefac_av_all1 + rate_pefac_av;
    
    for myd = 1:num_SNR
        rate_bana_av_dB(:,myd) = rate_bana_av_dB(:,myd) + rate_bana(:,myd);
        rate_hps_av_dB(:,myd) = rate_hps_av_dB(:,myd) + rate_hps(:,myd);
        rate_yin_av_dB(:,myd) = rate_yin_av_dB(:,myd) + rate_yin(:,myd);
        rate_cep_av_dB(:,myd) = rate_cep_av_dB(:,myd) + rate_cep(:,myd);
        rate_praat_av_dB(:,myd) = rate_praat_av_dB(:,myd) + rate_praat(:,myd);
        rate_pefac_av_dB(:,myd) = rate_pefac_av_dB(:,myd) + rate_pefac(:,myd);
    end
end

rate_bana_av_all1 = rate_bana_av_all1/num_list;
rate_hps_av_all1 = rate_hps_av_all1/num_list;
rate_yin_av_all1 = rate_yin_av_all1/num_list;
rate_cep_av_all1 = rate_cep_av_all1/num_list;
rate_praat_av_all1 = rate_praat_av_all1/num_list;
rate_pefac_av_all1 = rate_pefac_av_all1/num_list;

rate_bana_av_dB = rate_bana_av_dB/num_list;
rate_hps_av_dB = rate_hps_av_dB/num_list;
rate_yin_av_dB = rate_yin_av_dB/num_list;
rate_cep_av_dB = rate_cep_av_dB/num_list;
rate_praat_av_dB = rate_praat_av_dB/num_list;
rate_pefac_av_dB = rate_pefac_av_dB/num_list;

% Gross Pitch Error (GPE) rate
GPE_bana = 1-rate_bana_av_all1;
GPE_hps = 1-rate_hps_av_all1;
GPE_yin = 1-rate_yin_av_all1;
GPE_cep = 1-rate_cep_av_all1;
GPE_praat = 1-rate_praat_av_all1;
GPE_pefac = 1-rate_pefac_av_all1;

% save data
save(saveFilename);


% plot GPE rates vs. SNR for all algorithms averaged over 8 types of noise
% and 5 noise levels
fig1 = figure;
hold on;
linestyles = cellstr(char('--r','-k','-g','-b','-c','-m'));
markers=['s','d','>','*','x','o'];
plot(SNR_dB1,GPE_bana*100,[linestyles{1} markers(1)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_hps*100,[linestyles{2} markers(2)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_yin*100,[linestyles{3} markers(3)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_praat*100,[linestyles{4} markers(4)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_cep*100,[linestyles{5} markers(5)],'LineWidth',2,'MarkerSize',10);
plot(SNR_dB1,GPE_pefac*100,[linestyles{6} markers(6)],'LineWidth',2,'MarkerSize',10);
legend('BaNa','HPS','YIN','Praat','Cepstrum','PEFAC','Location','NorthEast');
h1 = xlabel('SNR (dB)'); 
h2 = ylabel('Gross Pitch Error Rate (GPE) (%)');
set(h1,'fontsize',14);
set(h2,'fontsize',14);
set(gca,'fontsize',14,'XTick',SNR_dB1);
ylim([0 80]);
set(fig1,'WindowStyle','normal'); 
set(fig1,'Position',[50 50 650 500]);
grid on;

% plot GPE rates of BaNa vs. YIN vs. PEFAC with 0dB SNR for all 8 types of noise (bar graph)
fig2 = figure;
dBindex2 = find(SNR_dB1==0);
plot_data = [1-rate_bana_av_dB(:,dBindex2) 1-rate_pefac_av_dB(:,dBindex2) 1-rate_yin_av_dB(:,dBindex2)];
bar(plot_data*100,'group')
set(gca,'XTickLabel',{'babble', 'engine', 'operation', 'factory', 'highfreq', 'pink', 'vehicle', 'white'})
legend('BaNa','PEFAC','YIN','Location','NorthEast');
h1 = xlabel('Type of noise'); h2 = ylabel('Gross Pitch Error Rate (GPE) (%)'); 
set(h1,'fontsize',14);
set(h2,'fontsize',14); 
set(gca,'fontsize',12);
set(gca,'YGrid','on');
