function [z, dataOCTlin] = raw2ascan(data, ReferenceArm, SampleArm)

    % Note, all data is in column format.

    if nargin == 1
        ReferenceArm = zeros(size(data));
        SampleArm = zeros(size(data));
    elseif nargin == 3
        % This is fine, too.
    else
        error('Number of input arguments seems incorrect');
    end

    % Dispersion correction parameters
    %a2 = -1e-6;
    %a3 = -35e-9; 
    a2 = 0;
    a3 = 0; 

    % Crops
    pix = (780:1720).'; % Spectral domain crop
    ncrop = 25; % DC crop
    
    % Calibration
    lam_cal = [832 846 860].';
    %pix_cal = [1048 1253 1419].'; % Low power
    pix_cal = [994 1218 1407].'; % High power
    
    % Use calibration to determine which pixel is which wavelength
    % Fitting function expects data in column format.
    fres = fit(pix_cal, lam_cal, 'poly1');
    lam = feval(fres, pix.');
    
    % Convert to regularly-spaced k-vectors
    k = (2 * pi)./lam;
    Dk = max(k) - min(k);
    dk = Dk/length(k);
    dz = 1/Dk*1e-9;
    kfit = (min(k):dk:max(k)).';

    % Extract out central row
    data = double(data(50, :));
    ReferenceArm = double(ReferenceArm(50, :));
    SampleArm = double(SampleArm(50,:));
    
    % Interpolate data to obtain values at regularly-spaced ks.
    data = data - ReferenceArm - SampleArm;
    data = data(pix);
    data = interp1(k, data, kfit.','spline');

    % Dispersion compensation
    kdisp = -length(kfit)/2 + 1/2:length(kfit)/2 - 1/2; 
    dispcomp = exp(1i*(a2*kdisp.^2 + a3*kdisp.^3));
    data = data.*dispcomp;
    
    % Inverse Fourier transform
    data = abs(ifft(data));
    
    % Only take the one half of the spectrum/data
    % Removal of DC 
    dataOCTlin = data(ncrop:length(data)/2);
    z = (1:length(dataOCTlin))*dz;

end