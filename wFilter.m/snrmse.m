function [snr,mse]=snrmse(clean,after)
% 计算信噪比函数
% clean：纯净信号
% after：去噪后信号
Ps=sum(sum((clean-mean(mean(clean))).^2));
Pn=sum(sum((clean-after).^2));
snr=10*log10(Ps/Pn);
mse=(Pn/length(clean)).^0.5;
end