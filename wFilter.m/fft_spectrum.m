%fft频谱
[x,fs_in] = audioread('Audio\sing.wav');
%计算信号的傅里叶变换。
N = length(x);
Y = fft(x);
%计算双侧频谱 P2。然后基于 P2 和偶数信号长度 L 计算单侧频谱 P1。
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%定义频域 f 并绘制单侧幅值频谱 P1,与预期相符，由于增加了噪声，幅值并不精确等于 0.7 和 1,一般情况下，较长的信号会产生更好的频率近似值。
 f = fs*(0:(N/2))/N;
h_fft = figure
plot(P1) % f,
title('Single-Sided Amplitude Spectrum of X(t)')
axis([20 20000,-inf,inf])
xlabel('f (Hz)')
ylabel('|P1(f)|')