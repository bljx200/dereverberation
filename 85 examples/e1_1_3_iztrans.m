clear all;
syms z n;
%ֱ��iztrans��
X=z/(z-0.5);
x=iztrans(X,z,n)

%���ַ�ʽչ����
%b=1;
%a=[1 -0.5];
%[r,p,C] = residuez(b,a);
%x=r(1)*p(1)^n