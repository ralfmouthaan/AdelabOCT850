% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% 850nm spectral domain SO-OCT system
%
% Run this code to start up system.
% Script should only be run once, when first setting up.
%
% Last edit: 30 October (RPM)

%% Clear all variables 

clear variables; clc; close all;
addpath('Functions\')

%% Spectrometer camera

% Start up camera
Cam = AviivaCam();
Cam = Cam.Startup();

%%
% Determine camera properties
Width = Cam.GetWidth();
Height = Cam.GetHeight();
Gain = Cam.GetGain();
Exposure = Cam.GetExposure();

% Display camera properties
fprintf('Camera properties:\n');
fprintf(['  Width: ' num2str(Width) ]);
fprintf(['  Height: ' num2str(Height) '\n']);
fprintf(['  Gain: ' num2str(Gain) '\n']);
fprintf(['  Exposure: ' num2str(Exposure) '\n'])

% Start streaming
Cam = Cam.StartStreaming();

%% PI translation stage for controlling offset

%initialize PI stages;
%If failure, use PImove to initialize them first;
addpath ('C:\Program Files (x86)\Physik Instrumente (PI)\Software Suite\MATLAB_Driver' ); % If you are still using XP, please look at the manual for the right path to include.
addpath('C:\Program Files (x86)\Physik Instrumente (PI)\Software Suite\Development\C++\API'); % For the c-data we need to collect 
addpath('C:\ProgramData\PI\GCSTranslator')

Controller = PI_GCS_Controller ();
devicesUsb = Controller.EnumerateUSB('');
if length(devicesUsb)<1
    disp('Not enough PI stages found!');
    Controller.Destroy;
else
    disp(['Connect to...' devicesUsb]); 
end

offsetPIserials = devicesUsb{1}; %'PI C-863 Merc8ury SN 0145500852;
offsetPI = Controller.ConnectUSB (offsetPIserials );
offsetPI = offsetPI.InitializeController ();%startup stage;
ax = '1';
offsetPI.SVO ( ax, 1 ); %1: on; 0: off; % switch servo on for axis

% Setting the reference arm to 0 
offsetPI.FNL(ax)

disp ( 'Setting Offset to zero')
% Wait for the referencearm to have 
while(0 ~= offsetPI.IsMoving ( ax ) )
    pause ( 0.1 );
    fprintf('.');
end   

% Check position that position is correct
offsetPI.qPOS(ax)

% Move to home position
HomeOffset = 0.5;
movePI(offsetPI,HomeOffset,'1')

%% Galvo mirror

% find the device in matlab
d = daqlist("ni");

% Look at the information 
deviceInfo = d{1,'DeviceInfo'};

% Create dataacquisition
dq = daq("ni");
dq.Rate = 4000;
addoutput(dq, "Dev1", "ao0", "Voltage");
addoutput(dq, "Dev1", "ao1", "Voltage");

outputX = 0;
outputY = 0;
write(dq,[outputX outputY]);

pause(0.01)

%% Done

disp ( 'Startup completed - You can now take images')