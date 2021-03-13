%��--------------------------------------------------------------------------��
%  Function: Noise reducing and compressing for mono audio using wavelet.
%��--------------------------------------------------------------------------��
clear all;

%Read the Original Audio 
Fs=44100; 
T = 1/Fs;     
[x,fs_in] = audioread('Audio\origin_signal.wav');
x = resample(x,Fs,fs_in); %Turn the sample rate into 44100Hz
x = x.*0.5/rms(x);
t=(0:length(x)-1)/Fs; %time [s]

%����С����ػ�������/Define basic parameters about wavelet:
N=3; 
wname1='cmor3-3';
wname2='db20';
totalscal=256; %�߶�
Fc = centfrq(wname1); %С��������Ƶ��
SORH = 's'; %��ֵ����

% ѡ����
fprintf('��ѡ������Ҫ�Ĳ����� \n Please select the function:\n');
fprintf('1:С����Ƶ����  2:С����Ƶѹ�� \n 1:Denoising with wavelet 2:compressing with wavelet\n');
M1=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M1)
    case 1 %С����Ƶ����(Reduce audio noise using wavelet)
        %�������� ��Adding noise��
            SNR_n=10;%���������
            xn=awgn(x,SNR_n,'measured');%�����˹��������Adding white Gaussian noise)
            xn= xn.*0.5/rms(x);
            y=xn;       
            L = length(y);   
        %��С�����룺
            threshval = recursive(x,Fs,SNR_n);%������ֵ
            [C,L] = wavedec(xn,N,wname2);%��ɢС���ֽ⣬3��
            b = wthresh(C,SORH,threshval);%����
            xo = waverec(b,L,wname2);%�ع�
            xo = xo.*0.5/rms(xo);
        %���������wav�ļ���Audio�ļ���
            audiowrite('Audio\processed_origin_signal.wav',x,Fs);
            audiowrite('Audio\noise_signal.wav',xn,Fs);
            audiowrite('Audio\noise_reduced_signal.wav',xo,Fs);
            
            [snr_before,mse_before]=snrmse(x,xn);%���㽵����������������
            [snr_after,mse_after]=snrmse(x,xo);%���㽵����������������
            
fprintf('С����Ƶ��������ɡ�\n Audio noise reduce is complete.\n');
fprintf('����ǰ�ź������Ϊ%gdB���������Ϊ%g��\n',snr_before,mse_before);
fprintf('������ź������Ϊ%gdB���������Ϊ%g��\n',snr_after,mse_after);


% ѡ��������蹦�ܣ�choose functions after processing��
while(1==1)
fprintf('1�����Ա���Ƶ   2���鿴ʱƵ�Ա�ͼ   3,��������\n 1��Hearing the audio   2��Check time-frequency plane   3��Finish the process\n');
M2=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %��ǰ����Ƶ�Ա�(Hearing the audio before & after)
        fprintf('Now playing origin sound...\n')
        sound(x,Fs)
        pause(size(x)/Fs);
        pause(1);
        fprintf('Now playing noise sound ...\n')
        sound(xn,Fs)
        pause(size(x)/Fs);
        pause(1);
        fprintf('Now playing reduce-noise sound ...\n')
        sound(xo,Fs)
        pause(size(x)/Fs);
        pause(1);
        
    case 2 %ʱƵͼ
        c=2*Fc*totalscal;
        scals=c./(1:totalscal);%�߶�
        f=scal2frq(scals,wname1,1/Fs); % ���߶�ת��ΪƵ��
        coefs_x=cwt(x,scals,wname1);
        coefs_xn=cwt(xn,scals,wname1);
        coefs_xo=cwt(xo,scals,wname1);
        
        subplot(1,3,1)
    imagesc(t,f,abs(coefs_x));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,15000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('ԭʼ�ź�С��ʱƵͼ');
        subplot(1,3,2)
    imagesc(t,f,abs(coefs_xn));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,15000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('�����ź�С��ʱƵͼ');
        subplot(1,3,3)
    imagesc(t,f,abs(coefs_xo));
    set(gca,'YDir','normal');
    colorbar;
    caxis([0,1]);
    axis([-inf,inf,20,15000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('�����ź�С��ʱƵͼ');
case 3 %��������
    return;
    otherwise
        fprintf('��������������������롣��Invalid number,please insert the right number.��\n');
end
end

     case 2 %С����Ƶѹ��(Audio compression using wavelet)
         
       [C,L] = wavedec(x,N,wname2);%N����ɢС���ֽ�
       xc = wrcoef('a',C,L,wname2,N);%�ɽ��Ʒ����ؽ��ź�
       audiowrite('Audio\compressed_signal.wav',xc,Fs);%�洢ѹ�����wav�ļ�
       [snr,mse]=snrmse(x,xc);%����ѹ���������snr��������mse
       fprintf('С����Ƶѹ������ɡ�\n Audio compress is complete.\n');
       fprintf('ѹ�����ź������Ϊ%gdB���������Ϊ%g��\n',snr,mse);
       
         while(1==1)
fprintf('1����ѹ��ǰ��Ա���Ƶ   2���鿴ʱƵ�Ա�ͼ   3,�鿴ʱ��Ա�ͼ   4����������\n 1��Hearing the audio   2��Check time-frequency plane   3��Finish the process\n');
M2=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %��ǰ����Ƶ�Ա�(Hearing the audio before & after)
        fprintf('Now playing origin sound...\n')
        sound(x,Fs)
        pause(size(x)/Fs);
        pause(1);
        fprintf('Now playing compressed sound ...\n')
        sound(xc,Fs)
        pause(size(x)/Fs);
        pause(1);
        
        
    case 2 %ʱƵͼ
      c=2*Fc*totalscal;
        scals=c./(1:totalscal);%�߶�
        f=scal2frq(scals,wname1,1/Fs); % ���߶�ת��ΪƵ��
        coefs_x=cwt(x,scals,wname1);
        coefs_xc=cwt(xc,scals,wname1);
        
        subplot(1,2,1)
    imagesc(t,f,abs(coefs_x));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('ԭʼ�ź�С��ʱƵͼ');
        subplot(1,2,2)
    imagesc(t,f,abs(coefs_xc));
    set(gca,'YDir','normal');
    colorbar;
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('ѹ���ź�С��ʱƵͼ');
        
    case 3 %�ֲ�ʱ��Ա�ͼ
        subplot(2,1,1)
        plot(t(:,100000:100500),x(100000:100500,:));hold on;
        xlabel('ʱ�� time[s]');
        ylabel('���� Amplitude');
        title('ԭʼ�źžֲ�ʱ��ͼ Time domain diagram of part of original signal');
        subplot(2,1,2)
        plot(t(:,100000:100500),xc(100000:100500,:));
        xlabel('ʱ�� time[s]');
        ylabel('���� Amplitude');
        title('ѹ���źžֲ�ʱ��ͼ Time domain diagram of part of compressed signal');
    case 4 %��������
        return;
    otherwise
    fprintf('��������������������롣��Invalid number,please insert the right number.��\n');
end
end
      
end






