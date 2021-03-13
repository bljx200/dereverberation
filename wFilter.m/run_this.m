%┌--------------------------------------------------------------------------┐
%  本程序的功能：单声道信号的小波降噪与压缩。
%  Function: Noise reducing and compressing for mono audio using wavelet.
%└--------------------------------------------------------------------------┘
clear all;

%读取原始音频/Read the Original Audio 
fs=44100; %采样率/Sample rate [Hz]
[x,fs_in] = audioread('Audio\origin_signal.wav');
x = resample(x,fs,fs_in); %将采样率转换为44100Hz（Turn the sample rate into 44100Hz）
t=(0:length(x)-1)/fs; %音频持续时间[s]（time [s]）

%定义小波相关基础参数/Define basic parameters about wavelet:
N=2; %离散小波分解级数
wname1='cmor3-3';%时频图用小波
wname2='coif3';%降噪用小波
totalscal=256; %尺度
Fc = centfrq(wname1); %小波的中心频率
TPTR = 'rigrsure';%阈值规则
SORH = 's'; %阈值方法
SCAL = 'mln';%阈值尺度的调整方法

% 选择功能
fprintf('请选择你需要的操作： \n Please select the function:\n');
fprintf('1:小波音频降噪  2:小波音频压缩 \n 1:Denoising with wavelet 2:compressing with wavelet\n');
M1=input('输入序号并按回车：\n Please input the number and press ENTER:\n');

switch(M1)
    case 1 %小波音频降噪(Reduce audio noise using wavelet)
        %加入噪声 （Adding noise）
            SNR_p=10;%掺入噪声的百分比（The percentage of noise）
            SNR_p=10*log(100/SNR_p); %将白噪声的百分比转换为信噪比（Turn the percentage into SNR）
            xn=awgn(x,SNR_p);%加入高斯白噪声（Adding white Gaussian noise）
        %再使用小波降噪：
            xo=wden(xn,TPTR,SORH,SCAL,N,wname2);
            
        %输出处理后的wav文件至Audio文件夹
            audiowrite('Audio\noise_signal.wav',xn,fs);
            audiowrite('Audio\noise_reduced_signal.wav',xo,fs);
            
        [snr,mse]=snrmse(x,xo);%计算降噪后信噪比与均方误差
            
fprintf('小波音频降噪已完成。\n Audio noise reduce is complete.\n');
fprintf('降噪后信号信噪比为%gdB，均方误差为%g。\n',snr,mse);


% 选择降噪后所需功能（choose functions after processing）
while(1==1)
fprintf('1，听对比音频   2，查看时频对比图   3,结束程序\n 1，Hearing the audio   2，Check time-frequency plane   3，Finish the process\n');
M2=input('输入序号并按回车：\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %听前后音频对比(Hearing the audio before & after)
        fprintf('Now playing origin sound...\n')
        sound(x,fs)
        pause(size(x)/fs);
        pause(1);
        fprintf('Now playing noise sound ...\n')
        sound(xn,fs)
        pause(size(x)/fs);
        pause(1);
        fprintf('Now playing reduce-noise sound ...\n')
        sound(xo,fs)
        pause(size(x)/fs);
        pause(1);
        
    case 2 %时频图
        c=2*Fc*totalscal;
        scals=c./(1:totalscal);%尺度
        f=scal2frq(scals,wname1,1/fs); % 将尺度转换为频率
        coefs_x=cwt(x,scals,wname1);
        coefs_xn=cwt(xn,scals,wname1);
        coefs_xo=cwt(xo,scals,wname1);
        
        subplot(1,3,1)
    imagesc(t,f,abs(coefs_x));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('时间 time[s]');
    ylabel('频率 frequency[Hz]');
    title('原始信号小波时频图');
        subplot(1,3,2)
    imagesc(t,f,abs(coefs_xn));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('时间 time[s]');
    ylabel('频率 frequency[Hz]');
    title('含噪信号小波时频图');
        subplot(1,3,3)
    imagesc(t,f,abs(coefs_xo));
    set(gca,'YDir','normal');
    colorbar;
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('时间 time[s]');
    ylabel('频率 frequency[Hz]');
    title('降噪信号小波时频图');
case 3 %结束程序
    return;
    otherwise
        fprintf('数字输入错误，请重新输入。（Invalid number,please insert the right number.）\n');
end
end

     case 2 %小波音频压缩降噪(Audio compress using wavelet)
         
       [C,L] = wavedec(x,N,wname2);%N级离散小波分解
       xc = wrcoef('a',C,L,wname2,N);%由近似分量重建信号
       audiowrite('Audio\compressed_signal.wav',xc,fs);%存储压缩后的wav文件
       [snr,mse]=snrmse(x,xc);%计算降噪后信噪比snr与均方误差mse
       fprintf('小波音频压缩已完成。\n Audio compress is complete.\n');
       fprintf('压缩后信号信噪比为%gdB，均方误差为%g。\n',snr,mse);
       
         while(1==1)
fprintf('1，听压缩前后对比音频   2，查看时频对比图   3,查看时域对比图   4，结束程序\n 1，Hearing the audio   2，Check time-frequency plane   3，Finish the process\n');
M2=input('输入序号并按回车：\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %听前后音频对比(Hearing the audio before & after)
        fprintf('Now playing origin sound...\n')
        sound(x,fs)
        pause(size(x)/fs);
        pause(1);
        fprintf('Now playing compressed sound ...\n')
        sound(xc,fs)
        pause(size(x)/fs);
        pause(1);
        
        
    case 2 %时频图
      c=2*Fc*totalscal;
        scals=c./(1:totalscal);%尺度
        f=scal2frq(scals,wname1,1/fs); % 将尺度转换为频率
        coefs_x=cwt(x,scals,wname1);
        coefs_xc=cwt(xc,scals,wname1);
        
        subplot(1,2,1)
    imagesc(t,f,abs(coefs_x));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('时间 time[s]');
    ylabel('频率 frequency[Hz]');
    title('原始信号小波时频图');
        subplot(1,2,2)
    imagesc(t,f,abs(coefs_xc));
    set(gca,'YDir','normal');
    colorbar;
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('时间 time[s]');
    ylabel('频率 frequency[Hz]');
    title('压缩信号小波时频图');
        
    case 3 %局部时域对比图
        subplot(2,1,1)
        plot(t(:,100000:100500),x(100000:100500,:));hold on;
        xlabel('时间 time[s]');
        ylabel('幅度 Amplitude');
        title('原始信号局部时域图 Time domain diagram of part of original signal');
        subplot(2,1,2)
        plot(t(:,100000:100500),xc(100000:100500,:));
        xlabel('时间 time[s]');
        ylabel('幅度 Amplitude');
        title('压缩信号局部时域图 Time domain diagram of part of compressed signal');
    case 4 %结束程序
        return;
    otherwise
    fprintf('数字输入错误，请重新输入。（Invalid number,please insert the right number.）\n');
end
end

        
        
end






