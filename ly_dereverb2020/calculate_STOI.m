clear all;clc;
[x,fs] = audioread('Audio\male3_clean.wav');

x=x/max(abs(x));
%x=[x;0];%only for female3
z = x;

STOI = zeros(1,19);
for j = 1:19 %�����19�ֻ��� 
       i=(j+1)/10;
       rev_name = strcat('Audio\male3_two',num2str(i),'.wav');%Ū���Զ�������Ҳ̫������
       [z(:,j),fs] = audioread(rev_name);
       z(:,j)=z(:,j)/max(abs(z(:,j)));
       STOI(:,j) = stoi(x, z(:,j), fs);
end
e=1



