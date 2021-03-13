%--------------------------------------------------------------------------
% Detect onset of a room impulse response
%--------------------------------------------------------------------------
% Related paper:
% M. Jeub, C.M. Nelke, C. Beaugeant, and P. Vary:
% "Blind Estimation of the Coherent-to-Diffuse Energy Ratio From Noisy
% Speech Signals", Proceedings of European Signal Processing Conference
% (EUSIPCO), Barcelona, Spain, 2011
%--------------------------------------------------------------------------
% Copyright (c) 2011, Marco Jeub and Hauke Krueger
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
function h_onset = rir_onset_detection(h,fs,onset_method)

%--------------------------------------------------------------------------
% Check input arguments
%--------------------------------------------------------------------------
if nargin < 3
    onset_method = 2;
end;

if nargin < 2
    error('not enough input arguments');
end;

%--------------------------------------------------------------------------
% Onset detection
%--------------------------------------------------------------------------
switch onset_method
    case 1 % Conventional method
        [~,h_onset]=max(abs(h));   % h_onset is time delay due to sound propagation
    case 2 % Proposed method
        frame_size = 1e-3*fs;
        frame_shift = frame_size/2; % 50% overlap
        h_length = length(h);
        max_frame = zeros(1,floor(h_length/frame_shift)-1);
        k = 0;  % frame counter
        for cnt = 1:frame_shift:h_length-frame_size+1
            k = k + 1;
            % current frame
            h_frame = h(1,cnt:cnt+frame_size-1);
            % lokal maximum per frame
            max_frame(k) = max(abs(h_frame));
        end;
        % Find global maximum
        [~,max_pos] = max(max_frame);
        % Convert frame index to sample index
        idx2sample = linspace(1,h_length,k);
        h_onset = floor(idx2sample(max_pos));
    otherwise
        error('invalid method for onset detection selected');
end;
%--------------------------------------------------------------------------