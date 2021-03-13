%fftƵ��
[x,fs_in] = audioread('Audio\sing.wav');
%�����źŵĸ���Ҷ�任��
N = length(x);
Y = fft(x);
%����˫��Ƶ�� P2��Ȼ����� P2 ��ż���źų��� L ���㵥��Ƶ�� P1��
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%����Ƶ�� f �����Ƶ����ֵƵ�� P1,��Ԥ�������������������������ֵ������ȷ���� 0.7 �� 1,һ������£��ϳ����źŻ�������õ�Ƶ�ʽ���ֵ��
 f = fs*(0:(N/2))/N;
h_fft = figure
plot(P1) % f,
title('Single-Sided Amplitude Spectrum of X(t)')
axis([20 20000,-inf,inf])
xlabel('f (Hz)')
ylabel('|P1(f)|')