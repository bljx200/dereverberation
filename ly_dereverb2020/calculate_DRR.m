clear all;clc;
RT = zeros(1,19);
DRR = RT;

for j = 1:19 %�����19�ֻ��� 
       i=(j+1)/10;
       rev_name = strcat('Audio\male3_two',num2str(i),'.wav');%Ū���Զ�������Ҳ̫������
       %[z(:,j),fs] = audioread(rev_name);
       %z(:,j)=z(:,j)/max(abs(z(:,j)));
       [RT(:,j),DRR(:,j)] = iosr.acoustics.irStats(rev_name);       
end

