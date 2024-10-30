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

%% Spectrometer camera
Cam.StopStreaming();
Cam.Shutdown();
clear Cam

%% PI translation stage for offset
offsetPI.CloseConnection()

%% Done

disp ( 'Shutdown completed')