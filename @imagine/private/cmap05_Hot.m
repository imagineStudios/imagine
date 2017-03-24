function dColormap = Hot(iNBins, dGamma)

% -------------------------------------------------------------------------
% Process input
if ~nargin, iNBins = 256; end
iNBins = uint16(iNBins);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create look-up tables (pairs of x- and y-vectors) for the three colors
dX    = [0; 0.37; 0.74; 1].^(1/dGamma);
dYRed = [0;    1;    1; 1];
dYGrn = [0;    0;    1; 1];
dYBlu = [0;    0;    0; 1];
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Interpolate and concatenate vectors to the final colormap
dRedInt = interp1(dX, dYRed, linspace(0, 1, iNBins)');
dGrnInt = interp1(dX, dYGrn, linspace(0, 1, iNBins)');
dBluInt = interp1(dX, dYBlu, linspace(0, 1, iNBins)');

dColormap = [dRedInt, dGrnInt, dBluInt];
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION OptimalColor
% =========================================================================