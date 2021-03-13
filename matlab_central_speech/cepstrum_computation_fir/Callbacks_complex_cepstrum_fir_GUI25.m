function Callbacks_complex_cepstrum_fir_GUI25(f,C)
%SENSE COMPUTER AND SET FILE DELIMITER
switch(computer)				
    case 'MACI64',		char= '/';
    case 'GLNX86',  char='/';
    case 'PCWIN',	char= '\';
    case 'PCWIN64', char='\';
    case 'GLNXA64', char='/';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=C{1,1};
y=C{1,2};
a=C{1,3};
b=C{1,4};
u=C{1,5};
v=C{1,6};
m=C{1,7};
n=C{1,8};
lengthbutton=C{1,9};
widthbutton=C{1,10};
enterType=C{1,11};
enterString=C{1,12};
enterLabel=C{1,13};
noPanels=C{1,14};
noGraphicPanels=C{1,15};
noButtons=C{1,16};
labelDist=C{1,17};%distance that the label is below the button
noTitles=C{1,18};
buttonTextSize=C{1,19};
labelTextSize=C{1,20};
textboxFont=C{1,21};
textboxString=C{1,22};
textboxWeight=C{1,23};
textboxAngle=C{1,24};
labelHeight=C{1,25};
fileName=C{1,26};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %PANELS
% for j=0:noPanels-1
% uipanel('Parent',f,...
% 'Units','Normalized',...
% 'Position',[x(1+4*j) y(1+4*j) x(2+4*j)-x(1+4*j) y(3+4*j)-y(2+4*j)]);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GRAPHIC PANELS
for i=0:noGraphicPanels-1
switch (i+1)
case 1
graphicPanel1 = axes('parent',f,...
'Units','Normalized',...
'Position',[a(1+4*i) b(1+4*i) a(2+4*i)-a(1+4*i) b(3+4*i)-b(2+4*i)],...
'GridLineStyle','--');
case 2
graphicPanel2 = axes('parent',f,...
'Units','Normalized',...
'Position',[a(1+4*i) b(1+4*i) a(2+4*i)-a(1+4*i) b(3+4*i)-b(2+4*i)],...
'GridLineStyle','--');
case 3
graphicPanel3 = axes('parent',f,...
'Units','Normalized',...
'Position',[a(1+4*i) b(1+4*i) a(2+4*i)-a(1+4*i) b(3+4*i)-b(2+4*i)],...
'GridLineStyle','--');
case 4
graphicPanel4 = axes('parent',f,...
'Units','Normalized',...
'Position',[a(1+4*i) b(1+4*i) a(2+4*i)-a(1+4*i) b(3+4*i)-b(2+4*i)],...
'GridLineStyle','--');
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TITLE BOXES
for k=0:noTitles-1
switch (k+1)
case 1
titleBox1 = uicontrol('parent',f,...
'Units','Normalized',...
'Position',[u(1+4*k) v(1+4*k) u(2+4*k)-u(1+4*k) v(3+4*k)-v(2+4*k)],...
'Style','text',...
'FontSize',textboxFont{k+1},...
'String',textboxString(k+1),...
'FontWeight',textboxWeight{k+1},...
'FontAngle',textboxAngle{k+1});
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BUTTONS
for i=0:(noButtons-1)
enterColor='w';
if strcmp(enterType{i+1},'pushbutton')==1 ||strcmp(enterType{i+1},'text')==1
enterColor='default';
end
if (strcmp(enterLabel{1,(i+1)},'')==0 &&...
        strcmp(enterLabel{1,(i+1)},'...')==0) %i.e. there is a label
%creating a label for some buttons
uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i)-labelDist-labelHeight(i+1) ...
(m(2+2*i)-m(1+2*i)) labelHeight(i+1)],...
'Style','text',...
'String',enterLabel{i+1},...
'FontSize', labelTextSize(i+1),...
'HorizontalAlignment','center');
end
switch (i+1)
case 1
button1=uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i) (m(2+2*i)-m(1+2*i)) (n(2+2*i)-n(1+2*i))],...
'Style',enterType{i+1},...
'String',enterString{i+1},...
'FontSize', buttonTextSize(1+i),...
'BackgroundColor',enterColor,...
'HorizontalAlignment','center',...
'Callback',@button1Callback);
case 2
button2=uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i) (m(2+2*i)-m(1+2*i)) (n(2+2*i)-n(1+2*i))],...
'Style',enterType{i+1},...
'String',enterString{i+1},...
'FontSize', buttonTextSize(1+i),...
'BackgroundColor',enterColor,...
'HorizontalAlignment','center',...
'Callback',@button2Callback);
case 3
button3=uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i) (m(2+2*i)-m(1+2*i)) (n(2+2*i)-n(1+2*i))],...
'Style',enterType{i+1},...
'String',enterString{i+1},...
'FontSize', buttonTextSize(1+i),...
'BackgroundColor',enterColor,...
'HorizontalAlignment','center',...
'Callback',@button3Callback);
case 4
button4=uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i) (m(2+2*i)-m(1+2*i)) (n(2+2*i)-n(1+2*i))],...
'Style',enterType{i+1},...
'String',enterString{i+1},...
'FontSize', buttonTextSize(1+i),...
'BackgroundColor',enterColor,...
'HorizontalAlignment','center',...
'Callback',@button4Callback);
case 5
button5=uicontrol('Parent',f,...
'Units','Normalized',...
'Position',[m(1+2*i) n(1+2*i) (m(2+2*i)-m(1+2*i)) (n(2+2*i)-n(1+2*i))],...
'Style',enterType{i+1},...
'String',enterString{i+1},...
'FontSize', buttonTextSize(1+i),...
'BackgroundColor',enterColor,...
'HorizontalAlignment','center',...
'Callback',@button5Callback);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%USER CODE FOR THE VARIABLES AND CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize Variables
    alpha=0.85;
    Np=100;
    fs=10000;

% Name the GUI
    set(f,'Name','complex_cepstrum_two_fir_sequences_GUI');

% CALLBACKS
% Callback for button1 -- alpha: gain of delayed signal
 function button1Callback(h,eventdata)
     alpha=str2num(get(button1,'string'));
     if ~((alpha >= -0.99 && alpha <= 0.99))
        waitfor(errordlg('alpha must be between -0.99 and 0.99'));
        return
     end
 end

% Callback for button2 -- Np: delay of signal in samples
 function button2Callback(h,eventdata)
     Np=str2num(get(button2,'string'));
     if ~((Np >= 1 && Np <= 500))
        waitfor(errordlg('Np must be between 1 and 500'));
        return
     end
 end

% Callback for button3 -- compute complex cepstrum of FIR sequence 1
 function button3Callback(h,eventdata)
% compute complex cepstrum of fir sequence 1
    alpha=str2num(get(button1,'string'));
    [b,L,stitle,freq,BNmag_ph,phase_rad,nfft,cepl,xhat1,xhats3]=...
        cepstrum_fir_sequence1(alpha,Np);
    
% titleBox1 for sequence 1
	set(titleBox1,'String',stitle);
    set(titleBox1,'FontSize',25);
    
% plot sequence, log magnitude, unwrapped phase, complex cepstrum in the
% set of 4 graphics panels

% clear graphics Panel 4
    reset(graphicPanel4);
    axes(graphicPanel4);
    cla;
    
% plot fir sequence 1 in graphics Panel 4
    be=[b,zeros(1,L)];
    plot(0:2*L-1,be(1:2*L),'r','LineWidth',2),axis tight;
    xpp=['Time in Samples; fs=',num2str(fs),' samples/second'];
	xlabel(xpp),ylabel('Value');
    
% clear graphics Panel 3
    reset(graphicPanel3);
    axes(graphicPanel3);
    cla;
    
% plot log magnitude frequency response of fir sequence 1 in graphics Panel
% 3
    plot(freq,real(BNmag_ph(1:nfft/2+1)),'r','LineWidth',2);
	axis tight;xlabel('Frequency in Hz'),ylabel('Log Magnitude');
    
% clear graphics Panel 2
    reset(graphicPanel2);
    axes(graphicPanel2);
    cla;
    
    
% plot unwrapped phase of fir sequence 1 in graphics Panel 2
    plot(freq,imag(BNmag_ph(1:nfft/2+1)),'r','LineWidth',2);
        xlabel('Frequency in Hz'),ylabel('Unwrapped Phase in Radians');
        hold on,plot(freq,phase_rad(1:nfft/2+1),'b--','LineWidth',2);
        legend('unwrapped phase','wrapped phase');
        
  % clear graphics panel 1
    reset(graphicPanel1);
    axes(graphicPanel1);
    cla;
    
% plot complex cepstrums computed using analytical method and matlab
% routines in graphics Panel 1
    plot(-cepl:cepl,xhats3,'r','LineWidth',2),...
        axis tight;xlabel('Quefrency in Samples'),ylabel('Value');
        hold on,plot(-cepl:cepl,xhat1,'g--','LineWidth',2),...
            legend('complex cepstrum direct','matlab routine');
 end

% Callback for button4 -- compute complex cepstrum of FIR sequence 2
 function button4Callback(h,eventdata)
% compute complex cepstrum of fir sequence 2 
    alpha=str2num(get(button1,'string'));
 [b,L,stitle,freq,BNmag_ph,phase_rad,nfft,cepl,xhat1,xhats3]=...
     cepstrum_fir_sequence2(alpha,Np);
   
% set up titleBox1 for fir sequence 2
	set(titleBox1,'String',stitle);
    set(titleBox1,'FontSize',25);
    
% plot time domain, log magnitude, unwrapped phase, complex cepstrum for
% fir sequence 2 in the four graphics Panels

% clear graphics panel 4
    reset(graphicPanel4);
    axes(graphicPanel4);
    cla;
    
% plot fir sequence 2 in graphics Panel 4
    plot(0:L-1,b(1:L),'r','LineWidth',2),axis tight;
    xpp=['Time in Samples; fs=',num2str(fs),' samples/second'];
	xlabel(xpp),ylabel('Value');
    
% clear graphics panel 3
    reset(graphicPanel3);
    axes(graphicPanel3);
    cla;
    
% plot log magnitude frequency response of fir sequence 2 in graphics Panel
% 3 
    plot(freq,real(BNmag_ph(1:nfft/2+1)),'r','LineWidth',2);
	axis tight;xlabel('Frequency in Hz'),ylabel('Log Magnitude');
    
% clear graphics panel 2
    reset(graphicPanel2);
    axes(graphicPanel2);
    cla;
    
% plot unwrapped phase of fir sequence 2 in graphics Panel 2
    plot(freq,imag(BNmag_ph(1:nfft/2+1)),'r','LineWidth',2);
        xlabel('Frequency in Hz'),ylabel('Unwrapped Phase in Radians');
        hold on,plot(freq,phase_rad(1:nfft/2+1),'b--','LineWidth',2);
        legend('unwrapped phase','wrapped phase');
        
  % clear graphics panel 1
    reset(graphicPanel1);
    axes(graphicPanel1);
    cla;
    
% plot complex cepstrums computed using analytical method and matlab
% routines in graphics Panel 1
    plot(-cepl:cepl,xhats3,'r','LineWidth',2),...
        axis tight;xlabel('Quefrency in Samples'),ylabel('Value');
        hold on,plot(-cepl:cepl,xhat1,'g--','LineWidth',2),...
            legend('complex cepstrum direct','matlab routine');
 end

% Callback for button5 -- close GUI
 function button5Callback(h,eventdata)
     close(gcf);
 end
end