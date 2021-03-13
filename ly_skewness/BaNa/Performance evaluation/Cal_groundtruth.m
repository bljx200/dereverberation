clear all;
close all;
%
% Calculate ground truth F0 for multiple speech files. F0 ground truth
% values are calculated by averaging the detected F0 values of three
% algorithms: BaNa, YIN and Praat. If the detected F0 values deviate
% more than error_tolerance (10%), the frame is considered to be unvoiced.
%
% See the Bridge project website at Wireless Communication and Networking
% Group (WCNG), University of Rochester for more information: 
% http://www.ece.rochester.edu/projects/wcng/project_bridge.html
%
% Written by He Ba, Na Yang and Weiyang Cai, University of Rochester.
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

addpath('../BaNa F0 detection algorithm','../Other F0 detection algorithms'); % add source code for BaNa and YIN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Parameter settings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0min = 50;
f0max = 600;
timestep = 0.01;
time_per_window = 0.06;
error_tolerance = 0.1; % error tolerance for F0 detection on speech is 10%
DBname = 'Arctic'; % database name. Options: 'LDC', 'Arctic'.

cleanFiles_dir = ['Audio files/Clean speech/' DBname '/'];
groundtruth_path = ['Ground truth/Speech/' DBname '/gt_'];
Praat_dir = ['Praat detected F0/Speech/' DBname '/'];
  
files = dir(fullfile(cleanFiles_dir,'*.wav'));
for filenum = 1:length(files)
    filename = files(filenum).name;
    [~,nm]= fileparts(filename); % nm: filename without extension
    filenamefull = strcat([cleanFiles_dir nm '.wav']);
    [x,fs] = wavread(filenamefull);
    advance_len = timestep*fs;
    frame_len = time_per_window*fs; % number of samples per frame
    frame_num = floor((length(x)-frame_len)/advance_len)+1; % number of frames
    
    % BaNa
    voice_marker = ones(1,frame_num); % when calculating the F0 ground truth, assume all frames are voiced
    f0_bana =  Bana(x,fs,f0min,f0max,timestep,voice_marker);
    
    % YIN
    R = YIN(filenamefull); % output R is a structure
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

    % Praat
    textname = strcat([Praat_dir nm '.txt']);
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
    f0_praat = zeros(1,frame_num);
    for i = 1:l1
        if int32(m1(i)*1/timestep)<=frame_num
            f0_praat(int32(m1(i)*1/timestep)) = m2(i);
        end
    end
    
    % Calculate ground truth (gt)
    gt = zeros(1,frame_num);
    for i = 1:frame_num
        if max([f0_bana(i),f0_yin_match(i),f0_praat(i)])-min([f0_bana(i),f0_yin_match(i),f0_praat(i)]) > error_tolerance*min([f0_bana(i),f0_yin_match(i),f0_praat(i)])
            gt(i) = 0;
        else
            gt(i) = mean([f0_bana(i),f0_yin_match(i),f0_praat(i)]);
        end
    end
    
    % save ground truth to MAT file
    savename = strcat([groundtruth_path nm '.mat']);
    save(savename,'gt');
end
