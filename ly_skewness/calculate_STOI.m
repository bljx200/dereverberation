clear all;clc;
[x,fs] = audioread('Audio\female1_clean.wav');

x=x/max(abs(x));
z = x;

STOI = zeros(1,19);
tic
for j = 1:19 %�����19�ֻ��� 
       i=(j+1)/10;
       rev_name = strcat('Audio\female1_one',num2str(i),'.wav');%Ū���Զ�������Ҳ̫������
       [z(:,j),fs] = audioread(rev_name);
       z(:,j)=z(:,j)/max(abs(z(:,j)));
       STOI(:,j) = stoi(x, z(:,j), fs);
end
toc