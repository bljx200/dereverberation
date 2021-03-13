%[x,fs] = audioread('Audio\female1_clean.wav');
%统一采样率
% fs = 44100;
% x = resample(in,fs,fs_in); 
% x = x/max(abs(x));%归一化
% save ('x','x');
%audiowrite('Audio\male3_clean.wav',x,fs);%写幅值归一化的语音
%%
% %生成T60 = 0.5/1/1.5(s) 的RIR
% c = 342;              % Sound velocity (m/s)
% mic=[2.5 1.5 1.7];%话筒位置
% room=[7 11 3];   %房间大小
% s=[2.5 0.5 1.7];     %音源位置
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
%卷积求混响语音
[x,fs] = audioread('Audio\male3_clean.wav');
load h.mat;
   y = zeros(size(x,1),3);
   for j = 1:19 %卷积出19种混响 
       i=(j+1)/10;
       y(:,j) = filter(h(:,j), 1, x);
       y(:,j) = y(:,j)/max(abs(y(:,j))); %混响语音归一
       rev_name = strcat('Audio\male3_rev',num2str(i),'.wav');%弄出自动命名我也太厉害了
       audiowrite(rev_name,y(:,j),fs);
   end

