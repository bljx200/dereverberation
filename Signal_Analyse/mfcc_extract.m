function mfcc = mfcc_extract(x,k,fs,p,wlen,inc)
%x �����ź�
%k Ԥ��ǿϵ����һ��ȡ0.97����
%
%
%
%
%

%Ԥ��ǿ
xx=double(x);
xx=filter([1,-k],[1],x);

%��֡�Ӵ�
xseg = enframe(xx,hanning(wlen),inc)';
n2=fix(wlen/2)+1;

%����ÿ֡mfcc����
for i = 1:size(xx,1)
    y=xx(i,:);
    s = y' .* hanning(wlen); 
    t = abs(fft(s))
    t=t.^2;
    c1 = dctcoef*log(bank*t(1:n2));
    c2 = c1 .* w';
    m(i,:) = c2';
end


xfft = fft(xseg);
E = xfft^2





