% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to run quick B-scan measurement without reference subtraction
% or sample arm subtraction

clc; close all;
clearvars -except Cam Controller dq offsetPI;

%% Set up

% Define the placement on the galvo mirror (x y)
write(dq, [0 0]);

% Moving the sample to the 0-offset
Offset = 0;
movePI(offsetPI,Offset,'1')

% Ensure that the exposure time is the correct on
Cam = Cam.StopStreaming();
Cam.SetExposure(100); % in us
Cam = Cam.StartStreaming();

% No of Ascans
Ascan = 200;
x = linspace(0, 0.48, Ascan);

% Set voltage for galvo (B-scan size -  1V = 0.48mm)
% Move only in x-axis
MinVoltageX = 0; %
MaxVoltageX = 0.25; %
GalvoX = linspace(MinVoltageX,MaxVoltageX,Ascan);
VoltageY = 0;

%% Take measurement

clear OCTImage

for n = 1:Ascan

    fprintf('Image collection: Ascan %d \n',n)

    % Move galvo
    outputX = GalvoX(n);
    write(dq, [outputX VoltageY]);
    
    % Take image and process
    Image = Cam.GetImage();
    [z, dataOCTlin] = raw2ascan2(Image);
    OCTImage(:, n) = dataOCTlin;

end

%% Plot

OCTImagedB = 20*log10(OCTImage);

figure;
imagesc(x*1e3, z*1e6, OCTImagedB)
colormap(gray)
clim([-30 max(max(OCTImagedB))+5])
xlabel('um');
ylabel('um');
