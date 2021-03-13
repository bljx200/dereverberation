%--------------------------------------------------------------------------
% Blind estimation of the DIRECT-TO-REVERBERANT-ENERGY RATIO (DRR)
%--------------------------------------------------------------------------
% -> Example simulation script
%--------------------------------------------------------------------------
% Related paper:
% M. Jeub, C.M. Nelke, C. Beaugeant, and P. Vary:
% "Blind Estimation of the Coherent-to-Diffuse Energy Ratio From Noisy
% Speech Signals", Proceedings of European Signal Processing Conference
% (EUSIPCO), Barcelona, Spain, 2011
%
% The provided room impulse responses are a subset of the AIR
% database; the full database is available under:
% http://www.ind.rwth-aachen.de/air
%--------------------------------------------------------------------------
% Copyright (c) 2011, Marco Jeub
% Institute of Communication Systems and Data Processing
% RWTH Aachen University, Germany
% Contact information: jeub@ind.rwth-aachen.de
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the RWTH Aachen University nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%--------------------------------------------------------------------------
% Version history:
% v1.0 - initial version (August 2011)
%--------------------------------------------------------------------------
clear all;

addpath air
addpath utilities

%--------------------------------------------------------------------------
% Simulation settings
%--------------------------------------------------------------------------
% Please note that the algorithm is developed to work with the given
% simulation settings; any modification on one parameter might require an
% additional tuning of all other settings

simpar.fs = 16e3;   % sampling frequency (Hz)
simpar.c = 340;     % speed of sound (m/s)

% Speech file
wav_file = ['audio' filesep 'TSP1min48.wav'];

[s_clean,fs_wav] = wavread(wav_file);
s_clean = resample(s_clean,simpar.fs,fs_wav);
s_length = length(s_clean);
%--------------------------------------------------------------------------
% DRR estimation based on room impulse response
%--------------------------------------------------------------------------
simpar.direct_range = 5e-3*simpar.fs; % duration of direct path after onset

%--------------------------------------------------------------------------
% DRR estimator settings
%--------------------------------------------------------------------------
simpar.block_size = 20e-3 * simpar.fs;  % block size
simpar.frame_shift = simpar.block_size;     % frame shift

simpar.fft_size = 512;   % FFT length
simpar.num_bins = simpar.fft_size/2+1;

simpar.alpha_PSD_DRR = 0.85;     % smoothing factor for auto- and cross-PSD
simpar.alpha_coh_DRR = 0.5;      % smoothing factor for coherence
simpar.DRR_limits = [-20,+20];   % lower and upper threshold for estimate

simpar.DRR_msc_VAD_thres = 0.95;       % threshold for VAD
simpar.alpha_DRR_speech_active = 0.98; % smoothing factor (speech active)
simpar.alpha_DRR_speech_inactive = 1;  % smoothing factor (speech inactive)

% Theoretical diffuse coherence model
num_bins = simpar.fft_size/2+1;
frq_vec = linspace(1,simpar.fs/2,num_bins);   % Frequency vector
% (a) Binaural RIRs with microphone spacing of 0.17m
%     please note that the shadowing influence due to the head is neglected
%     for simplicity
mic_dist = 0.17;
coh_model_17 = sinc(2*frq_vec*mic_dist/simpar.c);
% (b) Mobile phone RIRS with microphone spacing 0.02m
mic_dist = 0.02;
coh_model_02 = sinc(2*frq_vec*mic_dist/simpar.c);

%--------------------------------------------------------------------------
% Simulation example
% (a) Binaural RIR, stairway hall, mic_dist = 1m, with dummy head
%--------------------------------------------------------------------------
% Load impulse response from AIR database
simpar.rir_type = 1;
simpar.room = 5;
simpar.azimuth = 90;
simpar.head = 1;
simpar.rir_no = 1;
% Coherence model dependent on RIR type and distance
simpar.coh_model_DRR = coh_model_17;
% load left and right channel
simpar.channel = 1;h_left = load_air(simpar);
simpar.channel = 0;h_right = load_air(simpar);
% compute reverberant speech
clear s_rev;
s_rev(1,:)=fftfilt(h_left,s_clean);
s_rev(2,:)=fftfilt(h_right,s_clean);
% true DRR calculated from impulse response
DRR_stairway = drr_rir(h_left, simpar.direct_range, simpar.fs);
% estimated DRR
% (please note that the signals must to be time-aligned)
DRR_est_stairway = DRR_est_framework(s_rev,simpar);

%--------------------------------------------------------------------------
% Simulation example
% (b) Binaural RIR, Lecture room, mic_dist = 3m, with dummy head
%--------------------------------------------------------------------------
% Load impulse response from AIR database
simpar.rir_type = 1;
simpar.room = 4;
simpar.azimuth = 90;
simpar.head = 0;
simpar.rir_no = 1;
% Coherence model dependent on RIR type and distance
simpar.coh_model_DRR = coh_model_17;
% load left and right channel
simpar.channel = 1;h_left = load_air(simpar);
simpar.channel = 0;h_right = load_air(simpar);
% compute reverberant speech
clear s_rev;
s_rev(1,:)=fftfilt(h_left,s_clean);
s_rev(2,:)=fftfilt(h_right,s_clean);
% true DRR calculated from impulse response
DRR_lecture = drr_rir(h_left, simpar.direct_range, simpar.fs);
% estimated DRR
% (please note that the signals must to be time-aligned)
DRR_est_lecture = DRR_est_framework(s_rev,simpar);

%--------------------------------------------------------------------------
% Simulation example
% (c) Mobile phone RIR with mock-up phone and microphone spacing 0.02m
%--------------------------------------------------------------------------
% Load impulse response from AIR database
simpar.rir_type = 2;
simpar.room = 8;
simpar.phone_pos = 1;
% Coherence model dependent on RIR type and distance
simpar.coh_model_DRR = coh_model_02;
% load left and right channel
simpar.channel = 1;h_left = load_air(simpar);
simpar.channel = 0;h_right = load_air(simpar);
% compute reverberant speech
clear s_rev;
s_rev(1,:)=fftfilt(h_left,s_clean);
s_rev(2,:)=fftfilt(h_right,s_clean);
% true DRR calculated from impulse response
DRR_corridor = drr_rir(h_left, simpar.direct_range, simpar.fs);
% estimated DRR
% (please note that the signals must to be time-aligned)
DRR_est_corridor = DRR_est_framework(s_rev,simpar);

%--------------------------------------------------------------------------
% Plot results
%--------------------------------------------------------------------------
num_frames = length(DRR_est_stairway);
fr2sec_idx = linspace(1,s_length/simpar.fs,num_frames);
sample2sec_idx = linspace(1,s_length/simpar.fs,s_length);

figure
subplot 411,hold on
plot(sample2sec_idx,s_clean);
title('Clean speech signal');
grid on,xlabel('Time [s]')

subplot 412,hold on
plot(repmat(DRR_stairway,1,floor(fr2sec_idx(end))),'-r','linewidth',1.5);
plot(fr2sec_idx,DRR_est_stairway)
title('Stairway hall (Binaural)');
legend('true DRR','estimated DRR');ylabel('DRR [dB]');xlabel('Time [s]')
grid on,box on;

subplot 413,hold on
plot(repmat(DRR_lecture,1,floor(fr2sec_idx(end))),'-r','linewidth',1.5);
plot(fr2sec_idx,DRR_est_lecture)
title('Lecture room (Binaural)');
legend('true DRR','estimated DRR');ylabel('DRR [dB]');xlabel('Time [s]')
grid on,box on;

subplot 414,hold on
plot(repmat(DRR_corridor,1,floor(fr2sec_idx(end))),'-r','linewidth',1.5);
plot(fr2sec_idx,DRR_est_corridor)
title('Corridor (Mobile phone)');
legend('true DRR','estimated DRR');ylabel('DRR [dB]');xlabel('Time [s]')
grid on,box on;

%--------------------------------------------------------------------------