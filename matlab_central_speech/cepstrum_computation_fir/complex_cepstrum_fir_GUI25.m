function complex_cepstrum_fir_GUI25
% Modifiable runGUI file
clc;
clear all;
addpath(genpath(strcat(pwd,filesep,'functions_lrr')));
% %SENSE COMPUTER AND SET FILE DELIMITER
% switch(computer)				
%     case 'MACI64',		char= '/';
%     case 'GLNX86',  char='/';
%     case 'PCWIN',	char= '\';
%     case 'PCWIN64', char='\';
%     case 'GLNXA64', char='/';
% end

% USER - ENTER FILENAME
fileName = 'complex_cepstrum_fir.mat';    
fileData=load(fileName);
temp=fileData(1).temp;

f = figure('Visible','on',...
'Units','normalized',...
'Position',[0,0,1,1],...
'MenuBar','none',...
'NumberTitle','off');

Callbacks_complex_cepstrum_fir_GUI25(f,temp);    %USER - ENTER PROPER CALLBACK FILE
%panelAndButtonEdit(f, temp);       % Easy access to Edit Mode

% Note comment PanelandBUttonCallbacks(f,temp) if panelAndButtonEdit is to
% be uncommented and used
end

% GUI 2.5 for complex cepstrum of 2 FIR sequences
% 2 Panels
%   #1 - data/parameters
%   #2 - graphics
% 4 Graphics Panels
%   #1 - fir sequence in time domain
%   #2 - fir sequence in log magnitude frequency domain
%   #3 - unwrapped phase of fir sequence
%   #4 - complex cepstrum of fir sequence
% 1 TitleBox
% 5 Buttons
%   #1 - editable button - alpha: fir sequence 1 parameter
%   #2 - editable button - Np: fir sequence 2 parameter
%   #3 - pushbutton - FIR 1 Cepstrum
%   #4 - pushbutton - FIR 2 Cepstrum
%   #5 - pushbutton - Close GUI