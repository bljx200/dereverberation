%[x,fs] = audioread('Audio\female1_clean.wav');
%ͳһ������
% fs = 44100;
% x = resample(in,fs,fs_in); 
% x = x/max(abs(x));%��һ��
% save ('x','x');
%audiowrite('Audio\male3_clean.wav',x,fs);%д��ֵ��һ��������
%%
% %����T60 = 0.5/1/1.5(s) ��RIR
% c = 342;              % Sound velocity (m/s)
% mic=[2.5 1.5 1.7];%��Ͳλ��
% room=[7 11 3];   %�����С
% s=[2.5 0.5 1.7];     %��Դλ��
% N_h = 4096;         % Number of samples
% T60 = 0.2:0.1:2.0;
% h=zeros(N_h,3);
% 
% for i=1:19
% h(:,i) = rir_generator(c, fs, mic, s, room, T60(i), N_h);
% h(:,i)=h(:,i)/max(abs(h(:,i)));
% end
% save ('h','h');
%%
%������������
[x,fs] = audioread('Audio\male3_clean.wav');
load h.mat;
   y = zeros(size(x,1),3);
   for j = 1:19 %�����19�ֻ��� 
       i=(j+1)/10;
       y(:,j) = filter(h(:,j), 1, x);
       y(:,j) = y(:,j)/max(abs(y(:,j))); %����������һ
       rev_name = strcat('Audio\male3_rev',num2str(i),'.wav');%Ū���Զ�������Ҳ̫������
       audiowrite(rev_name,y(:,j),fs);
   end

