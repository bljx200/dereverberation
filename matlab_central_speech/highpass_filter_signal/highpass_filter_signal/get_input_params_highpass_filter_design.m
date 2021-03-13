function [freq1,n,fsout]=get_input_params_highpass_filter_design(fidr);
%
% read in all input parameters for designing highpass filter for speech and
% audio processing
%
% Input:
%   fidr: channel for text file with input parameters
%
% Outputs:
%   freq1: edge frequency of stopband of highpass filter (at fsout=10000 Hz
%   rate)
%   n: length of FIR highpass filter
%   fsout: sampling rate for highpass filter design

% read in hp filter design parameters
%   freq1: frequency at stopband edge (Hz)
    line=fgetl(fidr);s=regexp(line,' ');
    freq1=str2num(line(1:s(1)-1));

% n: size of fir filter (insamples) for dc and hum removal
    line=fgetl(fidr);s=regexp(line,' ');
    n=str2num(line(1:s(1)-1));

% fsout: sampling rate in Hz
    line=fgetl(fidr);s=regexp(line,' ');
    fsout=str2num(line(1:s(1)-1));
end