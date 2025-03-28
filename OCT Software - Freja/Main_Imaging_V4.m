
% This code is used for imaging with the 850nm SO-OCT system. 

% It accounts for manual blockage of the reference and sample arm for
% extraction of the background

% Last edit: 14. October 2024 (Freja Hoeier)

%% Clear variables from last run

clear data2 ReferenceArm Image Data OCTSpectrum ImageSampleArm SampleData SampleArm
close all 

%% Manual changeable settings - Initial values

% Folder to save the images in
FolderName = "C:\Users\ipas.labpcs\Desktop\Software850OCT\AviivaCamMatlab\Results";

% Date of the experiments
date = '20241014' ;

% Which number of experiment this is on the day
Experiment = 1;

% Type of sample
Sample = 'Parafilm';

% Reference focus
RefValue = '400px';

% Sample height setting
SampleHeight = '61px';

% Power setting
PowerSetting = 'HP'; % LP (low power) or HP (High power)

% Offset based on µm on the motor
NoOffset = 1;

% Creating a offset array (based on mm on the motor)
OffsetsArray = 0.55 ;% [0 0.22 0.44 0.55 0.66 0.88];

% No of Ascans we want to take (B-scan - 1µm/px => 480px/V))
Ascan = 481; % add 1, as the first is always the last image

% Set voltage for galvo in the x-axis (B-scan size - 1V => 0.48mm)
MinVoltageX = -1; %
MaxVoltageX = 0; % 

% Creating a galvo movement array
GalvoX = linspace(MinVoltageX,MaxVoltageX,Ascan);

% Set voltage for the galvo in the Y-axis
VoltageY = 0; % min -4 Max 3V

% Exposure time for the camera (spectrometer)
ExposureValue = 100; % If multiple exposure times, they should be taken by themselves

% Value of the pause (Change with exposure time)
PauseValue = 0.1; 

%% Collect image

% Ensure that the exposure time is the correct on
Cam = Cam.StopStreaming();
Cam.SetExposure(ExposureValue);
Cam = Cam.StartStreaming();

waitfor(msgbox("Start by blocking the sample arm - Press okay when done"));
for ii=1:11 % Taking an average of 11(10) A/scans

    pause(PauseValue)

    ReferenceImage = Cam.GetImage();
    
    if ii > 1 % Excludes 1 image
        ReferenceArm(:,:,ii) = ReferenceImage;
    end

end


for i = 1:NoOffset % Making the offsets
        
    % Move the spatial offset
    movePI(offsetPI,OffsetsArray(i),ax)
    
    waitfor(msgbox("Now you are ready to take the images - Remember to remove the blokage - Press okay to start"));
    for n = 1:Ascan

        % Move Galvo in x-direction
        outputX = GalvoX(n);
        write(dq,[outputX VoltageY]);

        pause(PauseValue)
        
        % Take the image from the camera
        Image = Cam.GetImage();
        
        if n > 1
            % Save all the spectrum taken:
            OCTSpectrum(:,:,n,i) = Image;
        end

        fprintf('Image collection: Ascan %d and Offset %d \n',n,i)
        
    end

    waitfor(msgbox("Now block the reference arm - Press okay when done"));

    for nnn = 1:Ascan

        % Move Galvo in x-direction
        outputX = GalvoX(nnn);
        write(dq,[outputX VoltageY]);

        pause(PauseValue)
        
        % Take the image from the camera
        ImageSampleArm = Cam.GetImage();

       if nnn > 1

            % Save all the spectrum taken:
            SampleArm(:,:,nnn,i) = ImageSampleArm;
       end

        fprintf('Sample arm collection: Ascan %d and Offset %d \n',nnn,i)

    end
end


%% Save the data

waitfor(msgbox("Imaging is now done - Press okay to save everything"));

save(fullfile(FolderName,sprintf('%s_Expt%d_%s_850nmOCT_Ascan%d_Offset%d_Ref%s_Sample%s_%s.mat',date,Experiment,Sample,Ascan,size(OffsetsArray,2),RefValue,SampleHeight,PowerSetting)),...
    'OCTSpectrum','ReferenceArm','SampleArm','ExposureValue','OffsetsArray','GalvoX')
