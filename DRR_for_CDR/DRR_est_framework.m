%--------------------------------------------------------------------------
% Blind estimation of the DIRECT-TO-REVERBERANT-ENERGY RATIO (DRR)
%--------------------------------------------------------------------------
% -> Example framework for framewise DRR estimation
%--------------------------------------------------------------------------
% Syntax:
%   DRR_est = DRR_est_framework(x,simpar)
%
% Input arguments:
%   x:  input reverberant speech, dual-channel [2xM]
%       (please note that the signals must to be time-aligned)
%   simpar: struct with simulation parameters
%       block_size  : block size, e.g. 20e-3 * 16e3 = 20ms at 16kHz
%       frame_shift     : frame_shift, e.g. 50% ->  round(block_size/2)
%       fft_size    : FFT size (larger or equal block_size), e.g. 512
%       see DRR_est_init.m for further required parameters
% Output arguments:
%   DRR_est     : framewise DRR estimation
%
% Required external functions:
%   DRR_est_init.m, DRR_est_frame.m
%--------------------------------------------------------------------------
% Related paper:
% M. Jeub, C.M. Nelke, C. Beaugeant, and P. Vary:
% "Blind Estimation of the Coherent-to-Diffuse Energy Ratio From Noisy
% Speech Signals", Proceedings of European Signal Processing Conference
% (EUSIPCO), Barcelona, Spain, 2011
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
function DRR_est = DRR_est_framework(x,simpar)

%--------------------------------------------------------------------------
% Get parameters
%--------------------------------------------------------------------------
block_size = simpar.block_size;
frame_shift = simpar.frame_shift;
fft_size = simpar.fft_size;

%--------------------------------------------------------------------------
% Check input parameters
%--------------------------------------------------------------------------
[num_ch,x_length] = size(x);

if nargin < 2
    error('not enough input parameters');
end;

if fft_size < block_size
    error('FFT size must be equal or larger block size');
end;

if (num_ch ~= 2)
    error('Input signal <x> must be dual channel [2xN]');
end;

%--------------------------------------------------------------------------
% Inits
%--------------------------------------------------------------------------
% number of (non-redundant) used frequency bins
num_bins = fft_size/2+1;

% Analysis/synthesis window
win = hann(block_size+1); hann_win = sqrt(win(1:block_size)).';

% DRR estimator
DRR_handle = DRR_est_init(simpar);

%--------------------------------------------------------------------------
% Framewise processing
%--------------------------------------------------------------------------
k = 0;
for cnt = 1:frame_shift:x_length-block_size+1
    k = k+1;  % frame counter
    %----------------------------------------------------------------------
    % Segmentation, windowing and DFT
    %----------------------------------------------------------------------
    x1 = x(1,cnt:cnt+block_size-1);
    x2 = x(2,cnt:cnt+block_size-1);
    % Input signals
    X1 = fft(x1.*hann_win,fft_size);
    X2 = fft(x2.*hann_win,fft_size);
    % Remove redundant frequency bins
    X1 = X1(1,1:num_bins);
    X2 = X2(1,1:num_bins);
    
    %----------------------------------------------------------------------
    % DRR estimation
    %----------------------------------------------------------------------
    [DRR_est(k),DRR_handle] = DRR_est_frame(X1,X2,DRR_handle);
    
end
%--------------------------------------------------------------------------