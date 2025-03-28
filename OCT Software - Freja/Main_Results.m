% Looking at the results 

% two ways of doing it:
% 1. right after taking the image -> run the top 
% 2. Later on based on the file name in the results


%% 1. Looking at an image right after taking it
a2 = -1e-6;
a3 = -35e-9; 

% Convert the reference arm to the mean of 100 pixel from cam
Ref = mean(ReferenceArm,1);
Ref2 = mean(Ref,3);

figure
for k = 1:size(OCTSpectrum,4)
    for i= 1:size(OCTSpectrum,3)

        Data2 = mean(OCTSpectrum(:,:,i,k),1);
        Sample = mean(SampleArm(:,i,k),1);
    
        dataOCTlin = data2oct_Oct24(Data2,Ref2.',Sample.',a2,a3);
    
        OCTImage(:,i,k) = dataOCTlin;

    end 

    ax1(k) = subplot(1,size(OCTSpectrum,4),k);
    imagesc(20.*log10(OCTImage(:,:,k)));
    clim([-60 0])
    colormap(gray)
    title(sprintf('Offset %0.3f mm',OffsetsArray(k)))

end

%% 2. Loading in the results 

Interference =  load('C:\Users\ipas.labpcs\Desktop\Software850OCT\AviivaCamMatlab\Results\20241014_Expt1_Parafilm_850nmOCT_Ascan101_Offset1_Ref400px_Sample61px_HP');


%% Running through the different samples - with the entire spectrum (plus 100)
a2 = -1e-6;
a3 = -35e-9; 

% Convert the reference arm to the mean of 100 pixel from cam
Ref = mean(Interference.ReferenceArm,1);
Ref2 = mean(Ref,3);

figure
for k = 1:size(Interference.OCTSpectrum,4)
    for i= 1:size(Interference.OCTSpectrum,3)

        Data2 = mean(Interference.OCTSpectrum(:,:,i,k),1);
        Sample = mean(Interference.SampleArm(:,i,k),1);
    
        dataOCTlin = data2oct_Oct24(Data2,Ref2.',Sample.',a2,a3);
    
        OCTImage(:,i,k) = dataOCTlin;

    end 

    ax1(k) = subplot(1,size(Interference.OCTSpectrum,4),k);
    imagesc(20.*log10(OCTImage(:,:,k)));
    clim([-60 0])
    colormap(gray)
    title(sprintf('Offset %0.3f mm',Interference.OffsetsArray(k)))

end
linkaxes(ax1)