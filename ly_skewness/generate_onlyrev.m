%����ֻ�л��죬û��ֱ����������������
clear all;
[x,fs] = audioread('Audio\female3_clean.wav');
load h
h_rev = h;

for i=1:4096
    if h_rev(i,:)==1;
       h_rev(i,:) = 0; 
    end
end
save h_rev

for j = 1:19 %�����19�ֻ��� 
       i=(j+1)/10;
       female3_onlyrev(:,j) = filter(h_rev(:,j), 1, x);
   end
  save female3_onlyrev
