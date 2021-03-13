% comp_log_Mel receives a time domain speech signal and produces its
% log Mel filterbank coefficients. It is the Matlab counterpart of the
% feature extraction program provided with AURORA2 database. 
% Author: Xiao Xiong
% Created: 18 Jul, 2005
% Last Modified: 28 Jul, 2005
% Inputs: 
%       x   1-D time domain signal
% Outputs: 
%       hist_log_mel    the log Mel filterbank coefficients
%       hist_mel        the Mel filterbank coefficients
%       hist_abs        the spectral magnitude
%       logE            the log energy item needed in computing MFCC

% the fine version of wav2abs have half of the normal frame_shift, i.e.,
% its frame_shift is 5ms instead of 10ms.
function [Abs_x] = wav2abs(x,frame_shift);

FFT_length = 256;
Fs = 8000;              % for AURORA2 database, the sampling rate is 8k
frame_size = Fs * 0.025;    % 25ms frame
if nargin < 2
    frame_shift = Fs * 0.01;    % 10ms shift
end
frame_overlap = frame_size - frame_shift;
% FFT
fft_x = sfft(x,frame_size,frame_shift,Fs,FFT_length);
% get the magnitude
Abs_x = abs(fft_x(2:FFT_length/2+1,:))';