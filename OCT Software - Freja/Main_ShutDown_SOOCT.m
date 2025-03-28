% This code is used for shutting down the 850nm SO-OCT system. 

% This code should be run as the last before shutting everything down

% Last edit: 22. August 2024 (Freja Hoeier)

%% Stop streaming the camera (spectrometer)
Cam = Cam.StopStreaming();
Cam = Cam.Shutdown();
clear Cam

%% Turn off the PI controller
offsetPI.CloseConnection()

%% Clear all variables 

% clear all; clc; close all;

%% Tell that shoutdown is complete

disp ( 'Shutdown completed')