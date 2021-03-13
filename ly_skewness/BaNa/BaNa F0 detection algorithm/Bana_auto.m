function f0_decision = Bana_auto(x, fs, f0min, f0max, timestep, pthr1)
%
% BaNa F0 detection algorithm for speech
%
% Input arguments:
% x -> the speech data
% fs -> sample rate for speech data (unit: Hz)
% f0min -> lower bound of human speech F0 (unit: Hz)
% f0max -> higher bound of human speech F0 (unit: Hz)
% timestep -> the time offset of the detected F0 (unit: sec)
% pthr1 -> amplitude ratio of the two highest Cepstrum peaks, used for
% voiced/unvoiced detection. A higher value gives a more stringent threshold
% for voiced frame detection. If pthr1=1, all frames are regarded as voiced.
% pthr1 is a value greater than or equal to 1.
%
% Ouput:
% f0_decision -> the detected F0 for each frame.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Default input parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default ratio of the amplitude of the first two highest Cepstrum peaks.
if nargin <6
    pthr1 = 1.1; 
end

% default time offset of detected F0
if nargin <5
    timestep = 0.01; 
end

% default higher bound of human speech F0
if nargin <4
    f0max = 600; 
end

% default lower bound of human speech F0
if nargin <3
    f0min = 50; 
end

if nargin <2
    error('Lack of input arguments!') % there should be at least 2 arguments (speech data and fs) 
end

if (size(x,1)<size(x,2))
    x=x';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Parameter settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_per_window = 0.06;                             % frame length in second
Lmed = 5;                                           % median filter window length

point_per_window = round(time_per_window*fs);       % number of samples per frame
point_per_timestep=round(timestep*fs);              % number of samples per time step

ls=length(x);                                       % length of input speech data
frame_center=ceil(point_per_window/2);              % the center point of current frame
nfrm = floor((ls-point_per_window)/point_per_timestep)+1; % number of frames
f0_spec_max = zeros(nfrm,5); % spectral peak frequency
f0_cept_freq = zeros(nfrm,1); % cesptrum F0 
f0_decision = zeros(nfrm,1); % final F0 decision
voicemarker = zeros(nfrm,1); 

p1=[]; % highest F0 level
p2=[]; % 2nd highest F0 level
pd1=[]; % highest F0 level's F0 period
pd2=[]; % 2nd highest F0 level's F0 period

i=1;                                                %frame count
while (frame_center+point_per_window/2 <= ls)    
    xframe_orig=x(max(frame_center-ceil(point_per_window/2),1):frame_center+ceil(point_per_window/2),1); %original frame    
    xframe = xframe_orig-mean(xframe_orig); %zero mean
    
    frame_fft = abs(fft(xframe.*hann(length(xframe)),2^16)); %2^16 points fft
    frame_fft1 = frame_fft(1:2^15+1);
    frame_fft1 = frame_fft1/length(xframe);           
    frame_psd = frame_fft1.^2;                       %get the psd
    frame_psd(2:end -1) = frame_psd(2:end -1)/pi;
    freq_resolution = fs/(2^16);
    frequencies = (1:2^15+1)*freq_resolution;

    HzMin = floor(f0min/freq_resolution);   %lower cutoff frequency 
    HzMax = floor(5*f0max/freq_resolution); %higher cutoff frequency
    frame_spec = frame_psd;
    frame_spec(1:HzMin) = 0;                        %filtered out spectrum below minimum frequency
    frame_spec(HzMax:end) = 0;                      %filtered out spectrum above 5 times maximum frequency
    f0_spec_max_amp = max(frame_spec);              
    Peaks=findpeaks(frequencies,frame_spec,0,1/15 *f0_spec_max_amp,0.6*100/(fs/2^16),5,3);
    %here use the peak detection function provided by Thomas O’Haver, http://terpconnect.umd.edu/ toh/spectrum/PeakFindingandMeasurement.htm.
    
    for peak_num = 1:5                            %search for the first five peaks with the lowest frequency
        low_freq_peak = find(Peaks(:,2)==min(Peaks(:,2)));
        if length(low_freq_peak)<1
            break;
        end
        f0_spec_max(i,peak_num) = Peaks(low_freq_peak,2);
        Peaks(low_freq_peak,:) = NaN;
    end
        
    % cepstrum 
    % code from L. R. Rabiner and R. W. Schafer, 'Theory and Application of Digital Speech Processing'.
    ppdlow=round(fs/f0max);
    ppdhigh=round(fs/f0min);
    
    xframe1 = filter([1 -1],1,xframe); % high-pass filter
    frame_fft = abs(fft(xframe1.*hann(length(xframe1)),2^16)); %2^16 points fft
    xframe1t=log(frame_fft);
    xframec=ifft(xframe1t,2^16);
       
    % initialize local frame cepstrum over valid range from ppdlow to ppdhigh
    indexlow=ppdlow+1;
    indexhigh=ppdhigh+1;
    loghsp=xframec(indexlow:indexhigh);

    % find cepstral peak location (ploc) and level (pmax) and save results in
    % pd1 (for ploc) and p1 (for pmax)
    pmax=max(loghsp);
    ploc1=find(loghsp == pmax);
    ploc=ploc1+ppdlow-1;
    f0_cept_freq(i,1) = fs/ploc;
    p1=[p1 pmax];
    pd1=[pd1 ploc];
    
    % eliminate strongest peak in order to find highest secondary peak 
    % which is spaced away from primary peak
    % save secondary peak in pd2 and secondary level in p2
    n1=max(1,ploc1-4);
    n2=min(ploc1+4,length(loghsp));
    loghsp2=loghsp;
    loghsp2(n1:n2)=0;
    pmax2=max(loghsp2);
    p2=[p2 pmax2];
    ploc2=find(loghsp2 == pmax2);
    ploc2=ploc2+ppdlow-1;
    pd2=[pd2 ploc2];
       
    i=i+1;
    frame_center = frame_center + point_per_timestep;
end

for myf = 1:length(pd1)
    if pd1(myf) == 0
        f0_cept_freq(myf) = 0;
    else
        f0_cept_freq(myf) = fs/pd1(myf);
    end
end

% voice marker based on ratio of first two highest cepstrum peaks 
ppdf=smoothpitch(pd1,pd2,p1,p2,pthr1); % cepstrum F0 period
p1m=medf(ppdf,Lmed,length(pd1)); % median filter cepstrum
for myf = 1:length(p1m)
    if p1m(myf) == 0
        f0_cept_freq(myf) = 0;
        voicemarker(myf) = 0;
    else
        f0_cept_freq(myf) = fs/p1m(myf);
        voicemarker(myf) = 1;
    end
end

% find F0 candidates
[candidates_decision,candidate_Cscore] = f0_decision_maker(f0_spec_max,f0_cept_freq,f0min,f0max); 
isCurrentVoiced = 0;
for frame_index = 1:nfrm
    if isCurrentVoiced == 0
        if voicemarker(frame_index) == 0 % still in unvoiced segment
            f0_decision(frame_index) = 0;
        else % start of voiced seg. But do not know whether voiced seg ends. do nothing 
            onehead = frame_index; % mark start of voiced seg
            onetail = frame_index; % initialize end of voiced seg 
            isCurrentVoiced = 1;
        end
    else
        if voicemarker(frame_index) == 0 % end of voiced seg -> Start local Viterbi process
            oneSeg = candidates_decision(onehead:onetail,:); % F0 candidates in one voiced segment
            scoreSeg = candidate_Cscore(onehead:onetail,:); % F0 candidates' confidence scores in one voiced segment
            f0_decision(onehead:onetail) = Path_finder(oneSeg,scoreSeg); % local Viterbi on voiced frames
            isCurrentVoiced = 0;
        else % still in voiced seg
            if frame_index ~= nfrm % voiced seg not reach the last frame. do nothing
                onetail = frame_index;
            else % voiced seg reach the last frame -> Start local Viterbi algorithm
                onetail = frame_index;
                oneSeg = candidates_decision(onehead:onetail,:); % F0 candidates in one voiced segment
                scoreSeg = candidate_Cscore(onehead:onetail,:); % F0 candidates' confidence scores in one voiced segment
                f0_decision(onehead:onetail) = Path_finder(oneSeg,scoreSeg); % local Viterbi on voiced frames
            end
        end
    end
end