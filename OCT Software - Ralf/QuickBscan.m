% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to run quick B-scan measurement without reference subtraction
% or sample arm subtraction

clc; close all;
clearvars -except Cam Controller dq offsetPI HomeOffset;

%% Set up

% Define the placement on the galvo mirror (x y)
write(dq, [0 0]);

% Moving the sample to the 0-offset
% Offset = HomeOffset + 0.06;
% movePI(offsetPI,Offset,'1')

MiddleV = 0.0; % This voltage corresponds to the mid-point of the range where the spot is not aberrated
SpotSize = 30; % Spot size in um
xrange_um = 2000; % Scan range in um
NoAscans = round(xrange_um/SpotSize*2);
GalvoCal = 3287; % um per V
xrange_V = xrange_um/GalvoCal;
GalvoV = linspace(MiddleV - xrange_V/2, MiddleV + xrange_V/2, NoAscans);
x = (GalvoV - min(GalvoV))*GalvoCal/1000; % x coordinates in mm

% Cam = Cam.StopStreaming();
% Cam.SetExposure(750); % in us
% Cam.SetGain(0);
% Cam = Cam.StartStreaming();


%% Take measurement

clear OCTImage

NoOverExposed = 0;
for n = 1:NoAscans

    fprintf('Image collection: Ascan %d \n',n)
    write(dq, [GalvoV(n) 0]); % Move galvo
    Image = Cam.GetImage();
    if sum(sum(Image == 255)) > size(Image, 1)*size(Image, 2) * 0.02
        NoOverExposed = NoOverExposed + 1;
    end
    [z, dataOCTlin] = raw2ascan2(Image);
    OCTImage(:, n) = dataOCTlin;

end

fprintf('Overexposed Percentage = %0.2f\n', NoOverExposed/NoAscans*100)


%% Plot

OCTImagedB = 20*log10(OCTImage);

figure;
imagesc(x*1e3, z*1e6, OCTImagedB)
colormap(gray)
clim([-10 max(max(OCTImagedB))+1])
xlabel('x (\mum)');
ylabel('z (\mum)');
