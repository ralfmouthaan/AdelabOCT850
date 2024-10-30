
% This code is for finding the right place on the sample and also testing
% the imaging possible on the image 

%% Initial values

% Define the placement on the galvo mirror (x y)
write(dq,[0 0]);

% Moving the sample to the 0-offset
Offset = 0;
movePI(offsetPI,Offset,ax)

% Set the exposuretime (µs)
ExposureValue = 300;

% Ensure that the exposure time is the correct on
Cam = Cam.StopStreaming();
Cam.SetExposure(ExposureValue);
Cam = Cam.StartStreaming();

%% Used for alignment of the system

for i = 1:50000
    
    % Chnage value at higher exposure times
    pause(0.1)
    
    % Collect the image from the spectrum camera
    Image = Cam.GetImage();

    % Take average of the 100lines
    Data = mean(Image,1);
    
    % Show raw image of the spectrometer camera
    figure(1)
    imagesc(Image);
    clim([0 255]);
    axis image;
    colormap gray;
    title(i);
    drawnow;
    
    figure(2)
    % Show the raw spectrum
    subplot(1,2,1)
    plot(Data)
    ylim([0 255])
    title(i);
    drawnow;

    % Show the A-scan
    subplot(1,2,2)
    dataOCTlin = data2oct_Alignment(Data); 
    plot(dataOCTlin)
   %  ylim([0 0.15])

end

%% Looking at the B-scan

clear OCTImage

% No of Ascans
Ascan = 200;

% Set voltage for galvo in the x-axis (B-scan size -  1V = 0.48mm)
MinVoltageX = 0; %
MaxVoltageX = 0.25; %

% Creating a galvo movement array
GalvoX = linspace(MinVoltageX,MaxVoltageX,Ascan);

% Set voltage for the y-axis
VoltageY = 0;

for n = 1:Ascan

    % Move Galvo in x-direction
    outputX = GalvoX(n);
    write(dq,[outputX VoltageY]);

    pause(0.1)
    
    % Take the image from the camera
    Image = Cam.GetImage();

    % Take average of the 100lines
    Data = mean(Image,1);
    
    % Converting the spectrum to an A-scan    
    dataOCTlin = data2oct_Alignment(Data);%
 
    % Save all A-scans for B and offsets in one matrix
    OCTImage(:,n) = dataOCTlin;
    
    fprintf('Image collection: Ascan %d \n',n)

end

figure
imagesc(20.*log10(OCTImage(:,2:end)))
colormap(gray)
clim([-40 20])
% imshow((20.*log10(OCTImage(:,2:end))),[])
