function [fname]=get_input_params_test_highpass_filter_signal(fidr);
%
% MATLAB function to read in input parameters for testing MATLAB function
% highpass_filter_signal
%
% Input:
%   fidr: channel for text file with input parameters
%
% Outputs:
%   fname: filename of signal to be highpass filtered

% read in input signal filename
    line=fgetl(fidr);
    fname=line(1:length(line));
    fname=['',fname,''];
    
end


