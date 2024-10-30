function dataOCTlin = data2oct_Oct24(data,ReferenceArm,SampleArm,a2,a3)

pixel=2048;
ncrop=60; % Removal of the DC-component
intType = 'spline'; 

% define the wavelengths:
lam_cal = [832 846 860]; 

% Define the pixels
%pix_cal = [1048 1253 1419]; % low power
pix_cal = [994 1218 1407]; % High power


% Change the direction for the fitting
lam_cal3 = lam_cal';
pix_cal3 = pix_cal';

% Make a fet 
ftype = fittype('poly1');
fres = fit(pix_cal3,lam_cal3,ftype);

% Not sure what this does? 
lam = feval(fres,1:pixel);

% Convert the wavelength to k-values
lam2 = lam';
k2 = (2 * pi)./lam2;

% Flipping the k-value to be able convert correctly
k = fliplr(k2);

% Extrat the max and min values 
Dk = max(k)-min(k); 

% Find spacing between pixels
dk = Dk/(pixel-1);

% z -axis???
dz = 1/Dk; z = dz*(0:pixel-1); zPlot = (1e-6)*z(1+ncrop:pixel/2);

% Define the k-fitting 
kfit = min(k):dk:max(k);
kfit = kfit';

% Removal of the reference spectrum
data2 = data - ReferenceArm.' - SampleArm.';


% Need to flip the data since the k-values are flipped
datam = fliplr(data2);

% Convert the pixels to wavelengths in the image
datam2 = interp1(k,datam,kfit,intType);

% Windowing
% Gaus_Ham = max(datam3(:))*hamming(pixel);
% datam4 = Gaus_Ham./ datam3;

% % Dispersion compensation
k_total = ((1:pixel)-(pixel+1)/2)'; % Define the space
Disp_Comp = a2*k_total.^2+a3*k_total.^3;
datam5 = datam2.*repmat(exp(-1j*-Disp_Comp),1,size(datam2,2));
 

% Make the inverse fourier transform 
dataIfft=ifft(datam5);

% Absolute value
dataOCTlin2 = abs(dataIfft);

% Mirror image, so remove the DC and the mirrored image
dataOCTlin= dataOCTlin2(1+ncrop:pixel/2);

    
end