function [b,n]=design_plot_filter(ifilt,bwidth,tband,fs)
%
% design and plot IR and FR of HP, LP or BP FIR filter

% Inputs:
%   ifilt: filter type (1:HP, 2:LP, 3:BP)
%   bwidth: bandwidth of stop band(s) in Hz
%   tband: transition band width in Hz
%   fs: sampling rate of signal to be filtered
%
% Outputs:
%   b: filter impulse response
%   n: filter length minus 1 in samples

% determine n for each sampling rate
    if (fs == 6000) n=100;
    elseif (fs == 6667) n=130;
    elseif (fs == 8000) n=150;
    elseif (fs == 10000) n=170;
    elseif (fs == 16000) n=300;
    elseif (fs == 20000) n=350
    else
        fprintf('sampling rate incorrect \n');
        pause
    end
    
    if (ifilt == 1)    
% highpass design; set highpass cutoff frequency in Hz
        band1_start=0;
        band1_end=bwidth;
        band2_start=band1_end+tband;
        band2_end=fs/2;
    
% set firpm parameters, n,f,a as follows
        a=[0 0 1 1];
        f=[band1_start band1_end band2_start band2_end];
        f=2*f/fs;
        
    elseif (ifilt == 2)
        
% lowpass design; set lowpass cutoff frequency in Hz
        band1_start=0;
        band1_end=fs/2-tband-bwidth;
        band2_start=band1_end+tband;
        band2_end=fs/2;
    
% set firpm parameters, n,f,a as follows
        a=[1 1 0 0];
        f=[band1_start band1_end band2_start band2_end];
        f=2*f/fs;
        
    elseif (ifilt == 3)
        
% bandpass design; set lowpass and highpass cutoff frequencies in Hz
        band1_start=0;
        band1_end=bwidth;
        band2_start=band1_end+tband;
        band2_end=fs/2-tband-bwidth;
        band3_start=band2_end+tband;
        band3_end=fs/2;
        
% set firpm parameters, n,f,a as follows
        a=[0  0 1 1 0 0];
        f=[band1_start band1_end band2_start band2_end band3_start band3_end];
        f=2*f/fs;
        
    end
          
% design filter using firpm function
    fprintf('f:%6.2f %6.2f %6.2f %6.2f %6.2f %6.2f \n',f);
    b=firpm(n,f,a);
    b
    
% plot filter IR and FR
    % h1=figure(1);orient landscape;
    % set(h1,'Position', [280 276 990 660]);
    reset(graphicPanel2);
    axes(graphicPanel2);
    
% plot IR
    n1=0:n;
    % subplot(211);
    plot(n1,b,'r','LineWidth',2);
    xlabel('time in samples'),ylabel('filter level');
    axis tight, grid on;
    
% compute FR
    nfft=4096;
    [h,w]=freqz(b,1,nfft,'whole',fs);
    
    if (ifilt == 1)
    stitle=sprintf('highpass filter: band edges:%d %d %d %d Hz, length:%d, fs:%d',...
    band1_start,band1_end,band2_start,band2_end,n+1,fs);
    elseif (ifilt == 2)
    stitle=sprintf('lowpass filter: band edges:%d %d %d %d Hz, length:%d, fs:%d',...
    band1_start,band1_end,band2_start,band2_end,n+1,fs);
    elseif (ifilt == 3)
    stitle=sprintf('bandpass filter: band edges:%d %d %d %d %d %d Hz, length:%d, fs:%d',...
    band1_start,band1_end,band2_start,band2_end,band3_start,band3_end,n+1,fs);
    end
    
% plot log magnitude FR
    reset(graphicPanel1);
    axes(graphicPanel1);
    % subplot(212);
    plot(w(1:nfft/2+1),20*log10(abs(h(1:nfft/2+1))),'b','LineWidth',2);
    xlabel('frequency in Hz'),ylabel('log magnitude (dB)');
    axis tight, grid on;
    title(stitle);
    
    