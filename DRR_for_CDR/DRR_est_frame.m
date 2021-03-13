%--------------------------------------------------------------------------
% Blind estimation of the DIRECT-TO-REVERBERANT-ENERGY RATIO (DRR)
%--------------------------------------------------------------------------
% -> Framewise DRR estimation
%--------------------------------------------------------------------------
% Syntax:
%   [DRR,handle] = DRR_est_frame(X1,X2,handle)
%
% Input arguments:
%   X1: Reverberant DFT coefficients of Channel 1 for one frame
%   X2: Reverberant DFT coefficients of Channel 2 for one frame
%   handle: function handle (see DRR_est_init.m for further details)
%
% Output arguments:
%   DRR:    Estimated DRR for given frame
%   handle: function handle
%
% Required external functions:
%   thres.m
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
function [DRR,handle] = DRR_est_frame(X1,X2,handle)

%--------------------------------------------------------------------------
% Init
%--------------------------------------------------------------------------
frame_cnt = handle.frame_cnt;
DRR_mu_range = handle.DRR_mu_range;
DRR_limits = handle.DRR_limits;

DRR_msc_VAD_thres = handle.DRR_msc_VAD_thres;
alpha_DRR_speech_active = handle.alpha_DRR_speech_active;
alpha_DRR_speech_inactive = handle.alpha_DRR_speech_inactive;
DRR_smooth = handle.DRR_smooth;

alpha_PSD = handle.alpha_PSD;
auto_PSD1 = handle.auto_PSD1;
auto_PSD2 = handle.auto_PSD2;
cross_PSD = handle.cross_PSD;

coh_model = handle.coh_model;
coh_smooth = handle.coh_smooth;
alpha_coh = handle.alpha_coh;

%----------------------------------------------------------------------
% Auto- and cross-PSD by recursive smoothingby recursive smoothing
%----------------------------------------------------------------------
X1_sq = abs(X1).^2;
X2_sq = abs(X2).^2;

auto_PSD1 = alpha_PSD*auto_PSD1+(1-alpha_PSD)*X1_sq;
auto_PSD2 = alpha_PSD*auto_PSD2+(1-alpha_PSD)*X2_sq;
cross_PSD = alpha_PSD*cross_PSD+(1-alpha_PSD)*conj(X1).*X2;

%------------------------------------------------------------------
% Coherence estimation by recursive smoothing
%------------------------------------------------------------------
coh_tmp = cross_PSD./max(sqrt(auto_PSD1.*auto_PSD2),eps);
% recursive smoothing
coh_smooth = alpha_coh*coh_smooth+(1-alpha_coh)*coh_tmp;

%------------------------------------------------------------------
% DRR estimation
%------------------------------------------------------------------
DRR_tmp = (coh_model - real(coh_smooth))./(real(coh_smooth)-1);

%----------------------------------------------------------------------
% Adaptive smoothing factor for DRR smoothing
%----------------------------------------------------------------------
% MSC as voice activity detector (VAD)
% (without smoothing to allow for detection of sharp onsets and offsets)
coh_nosmooth = (conj(X1).*X2)./(sqrt(X1_sq.*X2_sq+eps)); % Coherence
msc_nosmooth = abs(coh_nosmooth).^2;
mean_MSC = mean(msc_nosmooth);
% Frequency independent alpha_DRR
if mean_MSC < DRR_msc_VAD_thres % no speech activity
    alpha_DRR = alpha_DRR_speech_inactive;
else % speech activity
    alpha_DRR = alpha_DRR_speech_active;
end;

%--------------------------------------------------------------------------
% Smoothing
%--------------------------------------------------------------------------
% Smoothing in linear scale individual for each bin
DRR_tmp(DRR_tmp <= 0) = eps;
DRR_tmp = thres(DRR_tmp,10.^(DRR_limits/10));
DRR_smooth = alpha_DRR*DRR_smooth+(1-alpha_DRR)*DRR_tmp;
DRR = mean(DRR_smooth(DRR_mu_range));
DRR = 10*log10(DRR);

%--------------------------------------------------------------------------
% Copy required output to handle for next processed frame
%--------------------------------------------------------------------------
handle.frame_cnt = frame_cnt + 1;
handle.DRR_smooth = DRR_smooth;
handle.auto_PSD1 = auto_PSD1;
handle.auto_PSD2 = auto_PSD2;
handle.cross_PSD = cross_PSD;
handle.mean_MSC(frame_cnt) = mean_MSC;
handle.coh_smooth = coh_smooth;
%--------------------------------------------------------------------------