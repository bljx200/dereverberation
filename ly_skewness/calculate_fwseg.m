clear all; clc;

fwseg_y = zeros(1,19);
tic
for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    y_name = strcat('Audio\female3_rev',rev,'.wav');    
    fwseg_y(:,i) = comp_fwseg('Audio\female3_clean.wav',y_name);
end
toc