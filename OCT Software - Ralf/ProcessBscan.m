% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to process full B-scan measurement, taking care to subtract
% reference and sample. Dispersion compensation is set in raw2ascan.

%% User-defined

clc;
clearvars -except Cam Controller dq offsetPI HomeOffset;
addpath('Functions\')

Foldername = 'Results/20250408 - Polyfilm Results/';
Filename = '20250408_PolyFilm_Offset0_850nmOCT - Rpt.mat';
RawData =  load([Foldername Filename]);

%%

Ref = RawData.ReferenceArm;

for i= 1:size(RawData.OCTSpectrum, 3) % Iterates over A-scans

    Data = RawData.OCTSpectrum(:, :, i);
    Sample = RawData.SampleArm(:, :, i);
    [z, OCTImage(:, i)] = raw2ascan2(Data, Ref, Sample);

end 

%% 

figure('Position', [200 200 300 800]);
OCTImage = OCTImage/max(median(OCTImage.'));
OCTImagedB = 20*log10(OCTImage);
imagesc(RawData.x*1e3, z*1e6, OCTImagedB);
xlabel('\mum'); ylabel('\mum');
clim([-40 10])
colormap(gray)
set(gca, 'FontSize', 14)
xtickangle(45)