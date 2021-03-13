% filter_design_hp_lp_bp

% select highpass filter (hp), lowpass filter (lp), or bandpass filter (bp)
    ifilt=input('filter type: (1 for hp, 2 for lp, 3 for bp):');

% set sampling rate, fs, to 1000 Hz; set filter length, n, to 350;
    fs=10000;
    n=350;
    tband=100;
    bwidth=100;
    
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
    
% plot filter IR and FR
    h1=figure(1);orient landscape;
    set(h1,'Position', [280 276 990 660]);
    
% plot IR
    n1=0:n;
    subplot(211),plot(n1,b,'r','LineWidth',2);
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
    subplot(212),plot(w(1:nfft/2+1),20*log10(abs(h(1:nfft/2+1))),'b','LineWidth',2);
    xlabel('frequency in Hz'),ylabel('log magnitude (dB)');
    axis tight, grid on;
    title(stitle);
    
    