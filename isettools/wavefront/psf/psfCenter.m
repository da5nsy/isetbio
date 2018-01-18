function [outPSF, peakRow, peakCol] = psfCenter(inPSF)
% Shift the maximum of the provided PSF to the center of the D grid
%
% Syntax:
%   [outPSF, peakRow, peakCol] = psfCenter(inPSF)
%
% Description:
%    Put the maximum of a PSF at the center of the two D grid. The volume
%    of what comes out is adjusted to match that which came in. 
%
% Inputs:
%    inPSF   - Input Point-Spread Function
%
% Outputs:
%    outPSF  - Output Point-Spread Function
%    peakRow - Row location of the input PSF Peak
%    peakCol - Column location of the input PSF Peak
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Note: JNM - Please check example 2 for accuracy and terseness]
%

% History:
%    08/26/07  dhb  Wrote it.
%    08/22/11  dhb  A 'round' should be a 'floor', I think.
%    07/23/12  dhb  Match out volume to in volume.
%    11/13/17  jnm  Comments, example & formatting
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    wvf0 = wvfCreate;
    oblique_astig = 0.75;
    wvf0 = wvfSet(wvf0, 'zcoeffs', oblique_astig, {'oblique_astigmatism'});
    wvf0 = wvfComputePSF(wvf0);
    psf0 = wvfGet(wvf0, 'psf');
    [m, n] = size(psf0);
    psfOffCenter = psf0(1:round(3 * m / 4), 1:round(3 * n / 4));
    psfCenter = psfCenter(psfOffCenter);
    figure;
    clf;

    subplot(1, 2, 1);
    mesh(psfOffCenter);
    title('Off Center PSF');
    view(0, 90);
    axis('equal');
    axis([0 150 0 150]);

    subplot(1, 2, 2);
    mesh(psfCenter);
    title('Centered PSF');
    view(0, 90);
    axis('equal');
    axis([0 150 0 150]);
%}
%{
    % This example only shows the circularly averaged PSF for L-cones
    theZernikeCoeffs = importdata('autrusseauStandardObserver.txt');
    % Cone sensitivities and equal energy weighting spectrum
    load('T_cones_ss2');
    conePsfInfo.S = S_cones_ss2;
    conePsfInfo.T = T_cones_ss2;
    conePsfInfo.spdWeighting = ones(conePsfInfo.S(3), 1);

    wls = SToWls([400 10 31]);
    wvf0 = wvfCreate;

    % Set important parameters - Autrusseau std. observer
    wvf0 = wvfSet(wvf0, 'measured pupil size', 6);
    wvf0 = wvfSet(wvf0, 'calc pupil size', 6);
    wvf0 = wvfSet(wvf0, 'zcoeffs', theZernikeCoeffs(:, 1));
    wvf0 = wvfSet(wvf0, 'measured wavelength', 570);
    wvf0 = wvfSet(wvf0, 'calc wavelengths', wls);
    wvf0 = wvfSet(wvf0, 'calc cone psf info', conePsfInfo);
    wvf0 = wvfSet(wvf0, 'number spatial samples', 497);
    sce = sceCreate(wls, 'none');
    wvf0 = wvfSet(wvf0, 'sce params', sce);

    wvfParams1 = wvf0;
    wvfParams1 = wvfComputePSF(wvfParams1);
    conePsf1 = wvfGet(wvfParams1, 'cone psf');

    lpsf = psfCenter(conePsf1(:, :, 1));
%}

% Use interpolation to recenter
[peakRow, peakCol] = psfFindPeak(inPSF);

% Interpolate data so peak is at or near (0, 0). Extrapolated values are
% assumed to be 0.
[m, n] = size(inPSF);
xIn = ((1:n) - peakCol);
yIn = ((1:m) - peakRow);
xOut = ((1:n) - (floor(n / 2) + 1));
yOut = ((1:m) - (floor(m / 2) + 1));

outPSF = interp2(xIn, yIn', inPSF, xOut, yOut', 'linear', 0);
outPSF = sum(inPSF(:)) * outPSF / sum(outPSF(:));

end
