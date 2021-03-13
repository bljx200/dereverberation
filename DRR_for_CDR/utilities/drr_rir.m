%--------------------------------------------------------------------------
% Direct-to-Reverberant Energy Ratio (DRR) from a given impulse response
%--------------------------------------------------------------------------
% Syntax:
%   drr_log = drr_rir(h,direct_range,fs,do_plot_onset,onset_method)
% Input arguments:
%   h:              (single channel) impulse response [1xM]
%   direct_range:   duration of direct path after onset
%   fs:             sampling frequency (Hz)
%   do_plot_onset:  Optional: Plot RIR and detected onset (default=0)
%   onset_method:   Optional: Select onset detection method (default=2)
%
% Output arguments:
%   drr_log: Direct-to-Reverberant Energy Ratio in (dB)
%
% Required functions:
%   rir_onset_detection.m
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
function drr_log = drr_rir(h,direct_range,fs,do_plot_onset,onset_method)

%--------------------------------------------------------------------------
% Check input arguments
%--------------------------------------------------------------------------
if nargin < 5
    onset_method = 2;
    do_plot_onset = 0;
end;

if nargin < 4
    do_plot_onset = 0;
end;

if nargin < 3
    error('drr_rir: not enough input parameters')
end;

if size(h,1) > 1
    error('drr_rir: impulse response should be a single row vector');
end;

direct_range = floor(direct_range); % ensure integer values

%--------------------------------------------------------------------------
% Onset detection
%--------------------------------------------------------------------------
h_onset = rir_onset_detection(h,fs,onset_method);

if do_plot_onset
    figure,hold on
    plot(h,'-k')
    plot(h_onset,h(h_onset),'or');
    plot(h_onset+direct_range,h(h_onset+direct_range),'ob');
    axis([0 2*h_onset min(h) max(h)]);
end;
%--------------------------------------------------------------------------
% RIR decomposition
%--------------------------------------------------------------------------
h_direct = h(1:h_onset + direct_range); % direct path
h_reverb = h(h_onset + direct_range + 1:end); % early + late path

%--------------------------------------------------------------------------
% DRR calculation
%--------------------------------------------------------------------------
drr = sum(h_direct.^2) / sum(h_reverb.^2);
drr_log = 10*log10(drr);
%--------------------------------------------------------------------------