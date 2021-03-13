% Add different types of noise with different noise levels to clean 
% speech/music files to generate single-channel noisy speech/music files.
%
% The path of the clean audio files and the pure noise files might need to 
% be adjusted properly.
%
% See the Bridge project website at Wireless Communication and Networking
% Group (WCNG), University of Rochester for more information: 
% http://www.ece.rochester.edu/projects/wcng/project_bridge.html
%
% Written by He Ba and Na Yang, University of Rochester.
% Cepstrum code provided by Lawrence R. Rabiner, Rutgers University and
% University of California at Santa Barbara.
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

clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Parameter settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thr_amp = 0.02; % absolute threshold of samples's amplitude (For CSTR and KEELE database: 0.001; others: 0.02)
noise_type1 = {'babble','white','destroyerengine','destroyerops','factory','hfchannel','pink','volvo'};
SNR_dB1 = [0 5 10 15 20]; 
pureNoise_dir = 'Audio files/Pure noise/';

% add noise to speech
DBname = 'Arctic'; % database name. Options: 'LDC', 'Arctic', 'CSTR', 'KEELE'. 
cleanFiles_dir = ['Audio files/Clean speech/' DBname '/'];
noisyFiles_dir = ['Audio files/Noisy speech/Noisy ' DBname '/'];

% % add noise to music
% instrument = 'piano'; % instrument name: 'violin', 'trumpet', 'clarinet', 'piano'.
% cleanFiles_dir = ['Audio files/Clean music/' instrument '/'];
% noisyFiles_dir = ['Audio files/Noisy music/Noisy ' instrument '/'];


% Read clean speech/music samples
files = dir(fullfile(cleanFiles_dir,'*.wav'));
for filnum = 1:length(files)
    filename = files(filnum).name;
    [~,nm]= fileparts(filename);
    [x,fs] = wavread([cleanFiles_dir filename]);
    if (size(x,1)<size(x,2))
        x=x';
    end

    % for double channel file, choose the stronger channel
    if size(x,2) == 2
        energy_channel1 = dot(x(:,1),x(:,1));
        energy_channel2 = dot(x(:,2),x(:,2));
        if energy_channel1 > energy_channel2
            selected_channel = 1;
        else
            selected_channel = 2;
        end
        x = x(:,selected_channel);
    end

    % for samples with amplitude greater than a threshold, set sample marker to 1
    sample_marker = zeros(1,length(x));
    sample_marker(abs(x)>thr_amp) = 1;

    %% calculate RMS energy of signals on samples with sample_marker=1, adjust the noise level accordingly
    x_marked = x(sample_marker==1);
    RMS_signal = Cal_RMS(x_marked);
    for i=1:length(noise_type1)
        noise_type = noise_type1{i};  
        noise_file = [pureNoise_dir char(noise_type) '.wav'];
        [noise, fsn] = wavread(noise_file); 
        % resample noise
        noise = srconv(noise,fsn,fs);
        noise = noise(1:length(x)); % truncate noise to the same length as x  
        for j = 1:length(SNR_dB1)
            SNR_dB = SNR_dB1(j);  
            RMS_noise = Cal_RMS(noise); % noise RMS
            RMS_noise_scaled = RMS_signal/(10^(SNR_dB/20)); % target normalized signal RMS
            noise_scaled = noise*RMS_noise_scaled/RMS_noise; % noise_scaled/noise = RMS_noise_scaled/RMS_noise
            x_noisy = x + noise_scaled;

            % save noisy synthesized noisy speech/music to wave file
            syn_filename = [noisyFiles_dir nm '-' char(noise_type) '_' num2str(SNR_dB) 'dB.wav'];
            wavwrite(x_noisy,fs,syn_filename);
        end
    end
end
