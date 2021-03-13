%��--------------------------------------------------------------------------��
%  ������Ĺ��ܣ��������źŵ�С��������ѹ����
%  Function: Noise reducing and compressing for mono audio using wavelet.
%��--------------------------------------------------------------------------��
clear all;

%��ȡԭʼ��Ƶ/Read the Original Audio 
fs=44100; %������/Sample rate [Hz]
[x,fs_in] = audioread('Audio\origin_signal.wav');
x = resample(x,fs,fs_in); %��������ת��Ϊ44100Hz��Turn the sample rate into 44100Hz��
t=(0:length(x)-1)/fs; %��Ƶ����ʱ��[s]��time [s]��

%����С����ػ�������/Define basic parameters about wavelet:
N=2; %��ɢС���ֽ⼶��
wname1='cmor3-3';%ʱƵͼ��С��
wname2='coif3';%������С��
totalscal=256; %�߶�
Fc = centfrq(wname1); %С��������Ƶ��
TPTR = 'rigrsure';%��ֵ����
SORH = 's'; %��ֵ����
SCAL = 'mln';%��ֵ�߶ȵĵ�������

% ѡ����
fprintf('��ѡ������Ҫ�Ĳ����� \n Please select the function:\n');
fprintf('1:С����Ƶ����  2:С����Ƶѹ�� \n 1:Denoising with wavelet 2:compressing with wavelet\n');
M1=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M1)
    case 1 %С����Ƶ����(Reduce audio noise using wavelet)
        %�������� ��Adding noise��
            SNR_p=10;%���������İٷֱȣ�The percentage of noise��
            SNR_p=10*log(100/SNR_p); %���������İٷֱ�ת��Ϊ����ȣ�Turn the percentage into SNR��
            xn=awgn(x,SNR_p);%�����˹��������Adding white Gaussian noise��
        %��ʹ��С�����룺
            xo=wden(xn,TPTR,SORH,SCAL,N,wname2);
            
        %���������wav�ļ���Audio�ļ���
            audiowrite('Audio\noise_signal.wav',xn,fs);
            audiowrite('Audio\noise_reduced_signal.wav',xo,fs);
            
        [snr,mse]=snrmse(x,xo);%���㽵����������������
            
fprintf('С����Ƶ��������ɡ�\n Audio noise reduce is complete.\n');
fprintf('������ź������Ϊ%gdB���������Ϊ%g��\n',snr,mse);


% ѡ��������蹦�ܣ�choose functions after processing��
while(1==1)
fprintf('1�����Ա���Ƶ   2���鿴ʱƵ�Ա�ͼ   3,��������\n 1��Hearing the audio   2��Check time-frequency plane   3��Finish the process\n');
M2=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %��ǰ����Ƶ�Ա�(Hearing the audio before & after)
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
        
    case 2 %ʱƵͼ
        c=2*Fc*totalscal;
        scals=c./(1:totalscal);%�߶�
        f=scal2frq(scals,wname1,1/fs); % ���߶�ת��ΪƵ��
        coefs_x=cwt(x,scals,wname1);
        coefs_xn=cwt(xn,scals,wname1);
        coefs_xo=cwt(xo,scals,wname1);
        
        subplot(1,3,1)
    imagesc(t,f,abs(coefs_x));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('ԭʼ�ź�С��ʱƵͼ');
        subplot(1,3,2)
    imagesc(t,f,abs(coefs_xn));
    set(gca,'YDir','normal');
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('�����ź�С��ʱƵͼ');
        subplot(1,3,3)
    imagesc(t,f,abs(coefs_xo));
    set(gca,'YDir','normal');
    colorbar;
    caxis([0,1]);
    axis([-inf,inf,20,20000]);
    xlabel('ʱ�� time[s]');
    ylabel('Ƶ�� frequency[Hz]');
    title('�����ź�С��ʱƵͼ');
case 3 %��������
    return;
    otherwise
        fprintf('��������������������롣��Invalid number,please insert the right number.��\n');
end
end

     case 2 %С����Ƶѹ������(Audio compress using wavelet)
         
       [C,L] = wavedec(x,N,wname2);%N����ɢС���ֽ�
       xc = wrcoef('a',C,L,wname2,N);%�ɽ��Ʒ����ؽ��ź�
       audiowrite('Audio\compressed_signal.wav',xc,fs);%�洢ѹ�����wav�ļ�
       [snr,mse]=snrmse(x,xc);%���㽵��������snr��������mse
       fprintf('С����Ƶѹ������ɡ�\n Audio compress is complete.\n');
       fprintf('ѹ�����ź������Ϊ%gdB���������Ϊ%g��\n',snr,mse);
       
         while(1==1)
fprintf('1����ѹ��ǰ��Ա���Ƶ   2���鿴ʱƵ�Ա�ͼ   3,�鿴ʱ��Ա�ͼ   4����������\n 1��Hearing the audio   2��Check time-frequency plane   3��Finish the process\n');
M2=input('������Ų����س���\n Please input the number and press ENTER:\n');

switch(M2)
    case 1 %��ǰ����Ƶ�Ա�(Hearing the audio before & after)
        fprintf('Now playing origin sound...\n')
        sound(x,fs)
        pause(size(x)/fs);
        pause(1);
        fprintf('Now playing compressed sound ...\n')
        sound(xc,fs)
        pause(size(x)/fs);
        pause(1);
        
        
    case 2 %ʱƵͼ
      c=2*Fc*totalscal;
        scals=c./(1:totalscal);%�߶�
        f=scal2frq(scals,wname1,1/fs); % ���߶�ת��ΪƵ��
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






