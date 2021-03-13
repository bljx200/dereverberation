clear all; clc;

segsnr_y = zeros(1,19);
snr_y = segsnr_y;
for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    y_name = strcat('Audio\male3_two',rev,'.wav');    
    [snr_y(:,i),segsnr_y(:,i)] = comp_snr('Audio\male3_clean.wav',y_name);
end
a=1