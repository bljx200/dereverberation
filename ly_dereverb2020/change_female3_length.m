clear all; clc;

%读取
for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    rev_name = strcat('Audio\female3_rev',rev,'.wav');    
    [y(:,i),fs] = audioread(rev_name);
end

%加长
y=[y;zeros(1,19)];

%写入
for i=1:19
    rev = (i+1)/10;
    rev = num2str(rev);
    rev_name = strcat('Audio\female3_rev_ok',rev,'.wav');    
    audiowrite(rev_name,y(:,i),fs);
end
