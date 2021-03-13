% test_highpass_filter_signal
%
% test of function highpass_filter_signal.m
%
    clear all;
    
% read in filename with input parameters
    fidr=fopen('input_highpass_filter_signal.txt','r');
    
% read in hp filter design parameters
    [fname]=get_input_params_test_highpass_filter_signal(fidr);
    
% open signal file and read in signal samples; normalize to + or - 1 range
    [x,fsout]=loadwav(fname);
    xmax=max(max(x),-min(x));
    x=x/xmax;
    
% highpass filter signal
    y=highpass_filter_signal(x,fsout);
    
% play out input and highpass filtered signal
    soundsc(x,fsout);
    soundsc(y,fsout);