function zx = lpres( x )
fs=44100;
Nsig=length(x);
Tframe=40e-3;
p=12;
bs=Tframe*fs;
ss=bs/2;
% wn=hamming(bs);
wn=ones(bs,1);
a=mod(Nsig,ss);
b=zeros(ss-a,1);
x = [x;b];
zx=zeros(Nsig,1);
xn=x(1:bs);
an=aryule(xn.*wn,p);
zx(1:ss)=filter(an, 1, xn(1:ss));
for k=ss+1:ss:Nsig  %·Ö¶Î
    xn(1:ss)=xn(ss+1:end);
    xn(ss+1:end)=x(k:k+ss-1);
    an=aryule(xn.*wn,p);
    zf=filter(an, 1, xn);
    zx(k:k+ss-1)=zf(ss+1:end);
end
end

