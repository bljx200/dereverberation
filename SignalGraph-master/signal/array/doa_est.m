function [doaEst,tdoaCal] = doa_est(doa,tdoa,dist,micPosition,roomDimension)       
%
% INPUT: 
%    doa         ,  doa vector to be searched, in degrees, e.g., [1:1:359]';
%    tdoa        ,  estimated tdoa;
%    dist        , distance between the source and the array center;
%    micPosition ,  position of the microphones;
%    roomDimension    ,  size of the room.
% 
% OUTPUT:
%    doaEst        ,  estimated doa;
%    tdoaCal       ,  calculated tdoa;
% 
% %%%%%%%%%%%%%%%% uncomment this part to test the code %%%%%%%%%%%%%%%%
close all;
clear all;
clc;
echo off;

doa = 270;%(0:1:359);
%doa = test_doa + 0.5*randn(1,360)*pi/180; % comment to remove the randomness on the simulated DOAs
num = length(doa);
diameter=0.2;
roomDimension = [5,5,3];
microNumber = 8;
r1 = diameter/2; % radius of the circular array
deltaAngle = 2*pi/microNumber;
angle = 0:deltaAngle:deltaAngle*(microNumber-1);%2*pi*rand(OutStruct.microNumber/2,1);
deltaX = r1.*sin(angle)';
deltaY = r1.*cos(angle)';
deltaZ = -0.5.*ones(microNumber,1);
microCenter = roomDimension./2;
micPosition = repmat(microCenter,microNumber,1) + [deltaX deltaY deltaZ]; % This changes the area where the nodes are scattered.
c=340;  % sound velocity in the air;


%doa=89*pi/180;
dist=1;r=dist;
sourcePosition = repmat(microCenter,num,1) + [dist.*sin(doa.*pi./180)',dist.*cos(doa.*pi./180)',zeros(num,1)];
z=sourcePosition(1,3)-micPosition(1,3);

count=1;
for m=1:microNumber-1
    for n=m+1:microNumber
        d1 = sum((sourcePosition-repmat(micPosition(m,:),num,1)).^2,2).^(0.5);
        d2 = sum((sourcePosition-repmat(micPosition(n,:),num,1)).^2,2).^(0.5);
        tdoa(count,1) = (d1-d2)/c;
        count=count+1;
    end
end;
figure(100)
h0=plot(microCenter(1,1), microCenter(1,2),'ko');hold on;
h1=plot(micPosition(:,1),micPosition(:,2),'bo');hold on;
h2=plot(sourcePosition(:,1),sourcePosition(:,2),'r.');hold on;
set(h2,'lineWidth',2);
% h3=plot3(outStruct.x2,outStruct.y2,outStruct.z2,'r-');hold on;
% set(h3,'lineWidth',2)
xlabel('x/m')
ylabel('y/m')
%zlabel('z')
grid on
axis([0 roomDimension(1,1) 0 roomDimension(1,2)]);
%view(-50,10)
legend([],'microphone','source position');

%%%%tdoa = tdoa + 0.00001.*randn(size(tdoa));
doa = [0:1:359]';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

microCenter = roomDimension./2;%[2.5,2.5,1.5];

doa_rad = doa.*pi./180;      % convert doa in degrees into rad.
N = length(doa_rad);         % number of doa to be processed
M = size(micPosition,1); % number of microphones
%r=1;%dist;
x=r.*sin(doa_rad);
y=r.*cos(doa_rad);
c = 343;
sourcePosition = repmat(microCenter,N,1) + [x,y,zeros(N,1)];
count = 1;
for m=1:M-1
    for n=m+1:M
        d1 = sum((sourcePosition-repmat(micPosition(m,:),N,1)).^2,2).^(0.5);
        d2 = sum((sourcePosition-repmat(micPosition(n,:),N,1)).^2,2).^(0.5);
        tdoaCal(:,count) = (d1-d2)/c;
        count=count+1;
    end
end;
doa_error = sum((tdoaCal-repmat(tdoa',N,1)).^2,2);

[yy,doaIdx] = min(doa_error);
doaEst = doa(doaIdx);
