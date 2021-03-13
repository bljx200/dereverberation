% design_highpass_filter.m
%
    clear all;
    
% read in filename with input parameters
    fidr=fopen('input_design_highpass_filter.txt','r');
    
% read in hp filter design parameters
    [freq1,n,fsout]=get_input_params_highpass_filter_design(fidr);
    
% set filter specifications for remez design
    a=[0 0 1 1];  % highpass filter specification
    f=[0 2*freq1/fsout 4*freq1/fsout 1]; % highpass filter band edges
    
% design filter using remez design method
    b=firpm(n,f,a);
    nfft=4096;

% plot log magnitude frequency response
    [h,w]=freqz(b,1,nfft,'whole',fsout);
    stitle=sprintf('highpass filter: stopband edge:%d Hz, length:%d, fs:%d',...
        freq1,n+1,fsout);
    
% choose oversize figure
    h1=figure;orient landscape;
    set(h1,'Position',[280 278 990 660]);
    
    subplot(211),plot(w(1:nfft/2+1),20*log10(abs(h(1:nfft/2+1))),'r','LineWidth',2);
    xlabel('frequency in Hz'),ylabel('log magnitude (dB)');
    axis tight, grid on;
    title(stitle);

% display low end of frequency response (0-400 Hz region)
    ind1=round(2*freq1*nfft/fsout)+1;
    subplot(212),plot(w(1:ind1),20*log10(abs(h(1:ind1))),'b','LineWidth',2);
    xlabel('frequency in Hz'),ylabel('log magnitude (dB)');
    axis tight, grid on;
    
% save highpass filter coefficients in mat file filterhp
    filterhp=strcat('hpf_fsout_',num2str(fsout),'_n_',num2str(n),'_fstop_',...
        num2str(freq1),'.mat');
    save (filterhp, 'n', 'b');