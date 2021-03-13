clear all;
fs = 1000;
N = 1000;
f = 50;
n=0:N-1;
xn = cos(2*pi*f*n/fs);
y=dct(xn);
num = find(abs(y)<5);
y(num) = 0;
zn=idct(y);
subplot 211; plot(n,xn);
subplot 212; plot(n,zn);
rp = 100-norm(xn-zn)/norm(xn)*100 %计算重建率