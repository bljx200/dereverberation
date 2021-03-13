function [candidates_decision,candidates_Cscore] = f0_decision_maker(f0_spec_max,f0_cept_max,f0min,f0max)
%
% Use the frequency ratio of spectral peaks to find pitch candidates and
% their confidence scores.
%
% Input arguments:
% f0_spec_max -> the frequencies of five selected spectral peaks for each 
% frame. A matrix of size: number of frames x 5.
% f0_cept_max -> the Cepstrum pitch candidate
% f0min -> lower bound of human speech (unit: Hz)
% f0max -> higher bound of human speech (unit: Hz)
%
% Ouputs:
% candidates_decision -> calculated pitch candidates
% candidates_Cscore -> confidence scores of the calculated pitch candidates
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
candidates_decision = zeros(size(f0_spec_max,1),12); % at most 12 pitch candidates for each frame (2 out of 5 = 10 from peak ratios, 1 from the peak with the lowest freq., 1 from cepstrum)
candidates_Cscore = zeros(size(f0_spec_max,1),12); % confidence score of each pitch candidate

for frame = 1:size(f0_spec_max,1)
    spec_peaks = sort(f0_spec_max(frame,:)); % order spectral peaks in ascend order in order to calculate ratio
    while length(spec_peaks)<6
        spec_peaks(end+1) = 0;
    end
    candidates_ratio = zeros(5,5);
    candidates_ratio(2,1) = spec_peaks(1,2)/spec_peaks(1,1);
    candidates_ratio(3,1) = spec_peaks(1,3)/spec_peaks(1,1);
    candidates_ratio(4,1) = spec_peaks(1,4)/spec_peaks(1,1);
    candidates_ratio(3,2) = spec_peaks(1,3)/spec_peaks(1,2);
    candidates_ratio(4,2) = spec_peaks(1,4)/spec_peaks(1,2);
    candidates_ratio(4,3) = spec_peaks(1,4)/spec_peaks(1,3);
    candidates_ratio(5,1) = spec_peaks(1,5)/spec_peaks(1,1);
    candidates_ratio(5,2) = spec_peaks(1,5)/spec_peaks(1,2);
    candidates_ratio(5,3) = spec_peaks(1,5)/spec_peaks(1,3);
    candidates_ratio(5,4) = spec_peaks(1,5)/spec_peaks(1,4);
    
    f0_candidates =[];    
     
    if ~isempty(find(abs(candidates_ratio-4) <0.2, 1))
        [row,col] = find(abs(candidates_ratio-4) <0.2);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i));
        end
    end
    
    if ~isempty(find(abs(candidates_ratio-3) <0.2, 1))
        [row,col] = find(abs(candidates_ratio-3) <0.2);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i));
        end
    end
    
    if ~isempty(find(abs(candidates_ratio-2) <0.1, 1)) % ratio == 2
        [row,col] = find(abs(candidates_ratio-2) <0.1);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i));
        end
    end
    
    if ~isempty(find(candidates_ratio>1.42&candidates_ratio<1.59, 1)) %3/2
        [row,col] = find(candidates_ratio>1.42&candidates_ratio<1.59);
        for i = 1:length(col)
            f0_candidates(end+1) = 0.5* spec_peaks(1,col(i));
        end
    end
    
    if ~isempty(find(candidates_ratio>1.29&candidates_ratio<1.42, 1)) %4/3
        [row,col] = find(candidates_ratio>1.29&candidates_ratio<1.42);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i))/3;
        end
    end
    
    if ~isempty(find(abs(candidates_ratio-(5)) <0.2, 1))
        [row,col] = find(abs(candidates_ratio-(5)) <0.2);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i));
        end
    end
    
    if ~isempty(find(abs(candidates_ratio-(5/2)) <0.1, 1))
        [row,col] = find(abs(candidates_ratio-(5/2)) <0.1);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i))/2;
        end
    end
    
    if ~isempty(find(candidates_ratio>1.59&candidates_ratio<1.8, 1))%5/3
        [row,col] = find(candidates_ratio>1.59&candidates_ratio<1.8);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i))/3;
        end
    end
    
    if ~isempty(find(candidates_ratio>1.15&candidates_ratio<1.29, 1)) %5/4
        [row,col] = find(candidates_ratio>1.15&candidates_ratio<1.29);
        for i = 1:length(col)
            f0_candidates(end+1) = spec_peaks(1,col(i))/4;
        end
    end
   
    if length(f0_cept_max)>1
        f0_candidates(end+1) = f0_cept_max(frame);
    end    
    
    spec_peaks = spec_peaks(spec_peaks>f0min&spec_peaks<f0max); % discard candidates out of pitch region
    if ~isempty(spec_peaks)
        f0_candidates(end+1) = spec_peaks(1); % the spectral peak with the lowest frequency is included as one candidate
    end
    f0_candidates = f0_candidates(f0_candidates>f0min&f0_candidates<f0max);
    f0_candidates = sort(f0_candidates,'ascend');   
    
    % calculate confidence score for each candidate
    n = 1;
    while ~isempty(f0_candidates)
        best_candidate =[];
        max_similar_pitch_num =1;
        for i = 1:length(f0_candidates)
            similar_num = length(find(abs(f0_candidates-f0_candidates(i))<=10)); % combine close candidate withing 10 Hz
            if similar_num>max_similar_pitch_num
                max_similar_pitch_num = similar_num;
                best_candidate = f0_candidates(i);
            elseif similar_num==max_similar_pitch_num
                if isempty(best_candidate)
                    best_candidate = f0_candidates(i);
                else
                    if f0_candidates(i)< best_candidate
                        best_candidate = f0_candidates(i);
                    end
                end
            end
        end
        
        candidates_Cscore(frame,n) = max_similar_pitch_num;
        candidates_decision(frame,n) = best_candidate;
        f0_candidates = f0_candidates(abs(f0_candidates-best_candidate)>10); % combine close candidate withing 10 Hz
        n=n+1;
    end
end