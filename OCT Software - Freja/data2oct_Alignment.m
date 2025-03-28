function dataOCTlin = data2oct_Alignment(data)
pixel=2048;
ncrop=60;  
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

% Define the k-fitting 
kfit = min(k):dk:max(k);
kfit = kfit';

% Removal of the reference spectrum
data2 = data; 

% Need to flip the data since the k-values are flipped
datam = fliplr(data2);

% Convert the pixels to wavelengths in the image
datam2 = interp1(k,datam,kfit,intType);

% Need to flip the data back before doing the transformation
datam3 = flipud(datam2);

% Make the inverse fourier transform 
dataIfft=ifft(datam3);

% Absolute value
dataOCTlin2 = abs(dataIfft);

% Only take the one part of the spectrum/data + removal of DC 
dataOCTlin= dataOCTlin2(1+ncrop:pixel/2);

    
end