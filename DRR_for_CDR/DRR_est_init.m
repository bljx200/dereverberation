%--------------------------------------------------------------------------
% Blind estimation of the DIRECT-TO-REVERBERANT-ENERGY RATIO (DRR)
%--------------------------------------------------------------------------
% -> Initialization function
%--------------------------------------------------------------------------
% Syntax: 
%   handle = DRR_est_init(simpar)
%
% Input arguments:
%   simpar: struct with simulation parameters
%
% Output arguments:
%   handle: function handle for DRR estimation algorithm
%
% Required external functions:
%   -
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
function handle = DRR_est_init(simpar)

%--------------------------------------------------------------------------
% General initialization required for all DRR estimators
%--------------------------------------------------------------------------
handle.frame_cnt = 1;
handle.DRR_limits = simpar.DRR_limits;

handle.DRR_msc_VAD_thres = simpar.DRR_msc_VAD_thres;
handle.alpha_DRR_speech_active = simpar.alpha_DRR_speech_active;
handle.alpha_DRR_speech_inactive = simpar.alpha_DRR_speech_inactive;
handle.coh_model  = simpar.coh_model_DRR;

handle.alpha_PSD = simpar.alpha_PSD_DRR;
handle.auto_PSD1 = zeros(1,simpar.num_bins);
handle.auto_PSD2 = zeros(1,simpar.num_bins);
handle.cross_PSD = zeros(1,simpar.num_bins);

handle.alpha_coh = simpar.alpha_coh_DRR;
handle.coh_smooth = zeros(1,simpar.num_bins);
handle.DRR_mu_range = 1:length(simpar.coh_model_DRR);
handle.DRR_smooth = 0;

%--------------------------------------------------------------------------