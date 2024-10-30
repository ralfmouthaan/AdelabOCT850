% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to run full B-scan measurement, including reference arm
% measurement and sample arm measurement, and iterating over different
% offsets. The raw data is saved to a file and is subsequently processed by
% ProcessFullBscan.m.

%% Clear variables from last run

clearvars -except Cam Controller dq offsetPI;
clc; close all 

%% Manual changeable settings - Initial values

% Folder to save the images in
FolderName = "C:\Users\ipas.labpcs\Desktop\Software850OCT\AviivaCamMatlab\Results";

% Date of the experiments
date = '20241029' ;

% Which number of experiment this is on the day
Experiment = 1;

% Type of sample
Sample = 'Mirror';

% Reference focus
RefValue = '0.1mm';

% Sample height setting
SampleHeight = '0.1mm';

% Power setting
PowerSetting = 'LP'; % LP (low power) or HP (High power)

% Number of offsets
NoOffset = 1;

% Creating a offset array (based on mm on the motor)
OffsetsArray = 0 ;% [0 0.22 0.44 0.55 0.66 0.88];

% No of Ascans we want to take (B-scan - 1µm/px => 480px/V))
Ascan = 25; % add 1, as the first is always the last image

% Set voltage for galvo in the x-axis (B-scan size - 1V => 0.48mm)
MinVoltageX = 0; %
MaxVoltageX = 0.25; % 

% Creating a galvo movement array
GalvoX = linspace(MinVoltageX,MaxVoltageX,Ascan);

% Set voltage for the galvo in the Y-axis
VoltageY = 0; % min -4 Max 3V

ExposureValue = 50;

% Ensure that the exposure time is the correct on
Cam = Cam.StopStreaming();
Cam.SetExposure(ExposureValue);
Cam = Cam.StartStreaming();

%% Collect image

input('Please block sample arm...');

% REFERENCE SIGNAL
fprintf('Measuring reference arm only...\n')
ReferenceArm = Cam.GetImage();

for i = 1:NoOffset % Iterating over offsets
        
    % Move the spatial offset
    movePI(offsetPI, OffsetsArray(i), '1');
    
    % SAMPLE + REFERENCE SIGNAL
    input('Please unblock sample arm...')
    fprintf('Measuring sample and reference arms...\n')
    for n = 1:Ascan % Iterating over a-scans

        % Move Galvo in x-direction
        outputX = GalvoX(n);
        write(dq,[outputX VoltageY]);
        
        % Take the image from the camera
        OCTSpectrum(:, :, n, i) = Cam.GetImage();

        fprintf('Ascan %d and Offset %d \n',n,i)
        
    end

    %SAMPLE SIGNAL
    input('Please block reference arm...');
    fprintf('Measuring sample arm only...\n')

    for nnn = 1:Ascan

        % Move Galvo in x-direction
        outputX = GalvoX(nnn);
        write(dq,[outputX VoltageY]);
        
        % Take the image from the camera
        SampleArm(:,:,nnn,i) = Cam.GetImage();

        fprintf('Sample arm collection: Ascan %d and Offset %d \n',nnn,i)

    end
end


%% Save the data

fprintf("Saving Data...\n")

save(fullfile(FolderName,sprintf('%s_Expt%d_%s_850nmOCT_Ascan%d_Offset%d_Ref%s_Sample%s_%s.mat',date,Experiment,Sample,Ascan,size(OffsetsArray,2),RefValue,SampleHeight,PowerSetting)),...
    'OCTSpectrum','ReferenceArm','SampleArm','ExposureValue','OffsetsArray','GalvoX')
