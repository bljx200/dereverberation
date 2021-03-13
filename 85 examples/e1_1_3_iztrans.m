clear all;
syms z n;
%直接iztrans法
X=z/(z-0.5);
x=iztrans(X,z,n)

%部分分式展开法
%b=1;
%a=[1 -0.5];
%[r,p,C] = residuez(b,a);
%x=r(1)*p(1)^n