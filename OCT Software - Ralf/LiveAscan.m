% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to run live A-scan, showing camera image, raw spectrum and A-scan.

clc; close all;
clearvars -except Cam Controller dq offsetPI HomeOffset;

%% Set up

% Define the placement on the galvo mirror (x y)
write(dq, [0 0]);

% Moving the sample to the offset
Offset = HomeOffset + 0.00;
movePI(offsetPI,Offset,'1')

% Ensure that the exposure time is the correct on
Cam = Cam.StopStreaming();
Cam.SetExposure(200); % in us
Cam.SetGain(-10);
Cam = Cam.StartStreaming();

%% Live A-scan

figure;
while true
    
    % Collect and process data
    Image = Cam.GetImage();
    [z, dataOCTlin] = raw2ascan2(Image); 
    
    % Show raw image
    subplot(2, 2, [3, 4])
    imagesc(Image);
    clim([0 255]);
    axis image;
    colormap gray;
    
    % Show raw spectrum
    subplot(2,2,1)
    plot(Image(50,:))
    hold on
    yline(60, ':')
    hold off
    ylim([0 255])

    % Show A-scan
    subplot(2,2,2)
    plot(z*1e3, dataOCTlin)
    xlabel('z (mm)')

    maxval = max(max(dataOCTlin));
    maxidx = find(dataOCTlin == maxval);
    maxidx = maxidx(1);
    maxpos = z(maxidx)*1e3;

    fprintf('Max: %0.1fum, %0.2f\n', maxpos*1000, max(max(dataOCTlin)));

    drawnow;

end
