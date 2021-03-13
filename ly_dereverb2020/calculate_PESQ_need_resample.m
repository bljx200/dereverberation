clear all; clc;

PESQ_y = zeros(1,19);
fs_this = 16e3;

[x,fs] = audioread('Audio\male3_clean.wav');
x1 = resample(x,fs_this,fs); 
x1=x1/max(abs(x1));
audiowrite('clean.wav',x1,fs_this);

y = zeros(size(x,1),19);
% y=[y;zeros(1,19)];%only for female3
y1 = zeros(size(x1,1),19);
% y1=[y1;zeros(1,19)];%only for female3

for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    y_name = strcat('Audio\male3_two',rev,'.wav');
    [y(:,i),fs] = audioread(y_name);
    y1(:,i) = resample(y(:,i),fs_this,fs); 
    y1(:,i)=y1(:,i)/max(abs(y1(:,i)));
    audiowrite('enhanced.wav',y1(:,i),fs_this);
    PESQ_y(:,i) = comp_pesq('clean.wav', 'enhanced.wav');
    delete('enhanced.wav');
end
delete('clean.wav');
a=1