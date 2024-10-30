% Ralf Mouthaan & Freja Hoier
% University of Adelaide & DTU
% October 2024
% 
% Script to process full B-scan measurement, taking care to subtract
% reference and sample. Dispersion compensation is set in data2oct.

%% User-defined

clc;
clearvars -except Cam Controller dq offsetPI;

Interference =  load('C:\Users\ipas.labpcs\Desktop\Software850OCT\AviivaCamMatlab\Results\20241029_Expt1_Mirror_850nmOCT_Ascan25_Offset1_Ref0.1mm_Sample0.1mm_LP');

% No of Ascans
Ascan = 25;
x = linspace(0, 0.48, Ascan);

%%

Ref = Interference.ReferenceArm;

figure;
for k = 1:size(Interference.OCTSpectrum, 4) % Iterates over offsets
    for i= 1:size(Interference.OCTSpectrum, 3) % Iterates over A-scans

        Data = Interference.OCTSpectrum(:, :, i, k);
        Sample = Interference.SampleArm(:, :, i, k);
        [z, OCTImage(:, i, k)] = raw2ascan2(Data, Ref, Sample);

    end 

    ax1(k) = subplot(1, size(Interference.OCTSpectrum, 4), k);
    OCTImagedB = 20*log10(OCTImage(:, :, k));
    imagesc(x*1e3, z*1e6, OCTImagedB);
    clim([-40 max(max(OCTImagedB)) + 5])
    colormap(gray)
    title(sprintf('Offset %0.3f mm', Interference.OffsetsArray(k)))

end

linkaxes(ax1)