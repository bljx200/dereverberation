clear all; clc;

SRMR_y = zeros(1,19);
fs_this = 16e3;

[x,fs] = audioread('Audio\male1_clean.wav');
x1 = resample(x,fs_this,fs); 
x1=x1/max(abs(x1));

y = zeros(size(x,1),19);
y1 = zeros(size(x1,1),19);
tic
for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    y_name = strcat('Audio\male1_two',rev,'.wav');
    [y(:,i),fs] = audioread(y_name);
    y1(:,i) = resample(y(:,i),fs_this,fs); 
    y1(:,i)=y1(:,i)/max(abs(y1(:,i)));
    
    [SRMR_y(:,i), energy] = SRMR(y1(:,i), fs_this);
end
toc