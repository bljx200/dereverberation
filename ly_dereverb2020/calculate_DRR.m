clear all;clc;
RT = zeros(1,19);
DRR = RT;

for j = 1:19 %卷积出19种混响 
       i=(j+1)/10;
       rev_name = strcat('Audio\male3_two',num2str(i),'.wav');%弄出自动命名我也太厉害了
       %[z(:,j),fs] = audioread(rev_name);
       %z(:,j)=z(:,j)/max(abs(z(:,j)));
       [RT(:,j),DRR(:,j)] = iosr.acoustics.irStats(rev_name);       
end

