function [snr,mse]=snrmse(clean,after)
% ��������Ⱥ���
% clean�������ź�
% after��ȥ����ź�
Ps=sum(sum((clean-mean(mean(clean))).^2));
Pn=sum(sum((clean-after).^2));
snr=10*log10(Ps/Pn);
mse=(Pn/length(clean)).^0.5;
end