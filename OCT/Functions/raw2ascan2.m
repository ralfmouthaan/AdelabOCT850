% Ralf Mouthaan
% University of Adelaide
% October 2024
%
% Function to convert raw image data (assumed to be captured on AviivaCam
% camera, but others might also work) into an a-scan. 
%  - Crops out the region where the spectrum is non-zero
%  - Applies a wavelength calibration
%  - Converts to regularly spaced k-vectors
%  - Dispersion compensation
%  - Inverse Fourier transform
% 
% Can pass in just the interference spectrum (sample + reference), or can
% also pass in reference only and sample only. If this is done, then these
% are processed as above and subtracted from the sample + reference result.
% This is done at the end to avoid issues with interferometer instability
% and rolling shutter.
% 
% Finally, the data is trimmed to give one half of the symmetrical trace
% and the DC component is removed.

function [z, data] = raw2ascan2(data, ReferenceArm, SampleArm)

    % Note, all data is in column format.

    if nargin == 1
        % This is fine
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
    kdisp = -length(kfit)/2 + 1/2:length(kfit)/2 - 1/2; 
    dispcomp = exp(1i*(a2*kdisp.^2 + a3*kdisp.^3));

    data = double(data);

    % Camera has a rolling shutter, so we process each data row
    % individually
    for i = 1:size(data, 1)

        datarow = data(i,:);
    
        % Interpolate data to obtain values at regularly-spaced ks.
        datarow = datarow(pix);
        datarow = interp1(k, datarow, kfit.','spline');
    
        % Dispersion compensation
        datarow = datarow.*dispcomp;
        
        % Inverse Fourier transform
        datarow = abs(ifft(datarow));
        newdata(i,:) = datarow;

    end
    data = mean(newdata, 1);

    % Do we need to process sample arm and reference arm data?
    if nargin == 3

        SampleArm = double(SampleArm);
        ReferenceArm = double(ReferenceArm);

        % Process ReferenceArm
        for i = 1:size(ReferenceArm, 1)
    
            datarow = ReferenceArm(i,:);
        
            % Interpolate data to obtain values at regularly-spaced ks.
            datarow = datarow(pix);
            datarow = interp1(k, datarow, kfit.','spline');
        
            % Dispersion compensation
            kdisp = -length(kfit)/2 + 1/2:length(kfit)/2 - 1/2; 
            dispcomp = exp(1i*(a2*kdisp.^2 + a3*kdisp.^3));
            datarow = datarow.*dispcomp;
            
            % Inverse Fourier transform
            datarow = abs(ifft(datarow));
            NewReferenceArm(i,:) = datarow;
    
        end
        ReferenceArm = mean(NewReferenceArm, 1);
    
        % Process SampleArm
        for i = 1:size(SampleArm, 1)
    
            datarow = SampleArm(i,:);
        
            % Interpolate data to obtain values at regularly-spaced ks.
            datarow = datarow(pix);
            datarow = interp1(k, datarow, kfit.','spline');
        
            % Dispersion compensation
            kdisp = -length(kfit)/2 + 1/2:length(kfit)/2 - 1/2; 
            dispcomp = exp(1i*(a2*kdisp.^2 + a3*kdisp.^3));
            datarow = datarow.*dispcomp;
            
            % Inverse Fourier transform
            datarow = abs(ifft(datarow));
            NewSampleArm(i,:) = datarow;
    
        end
        SampleArm = mean(NewSampleArm, 1);
    
        % Now do the subtraction
        data = data - ReferenceArm - SampleArm;
        data = abs(data);

    end
    
    % Only take the one half of the spectrum/data
    % Removal of DC 
    data = data(ncrop:length(data)/2);
    z = (1:length(data))*dz;

end