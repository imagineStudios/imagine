function dColormap = French(iNBins, dGamma)
%OPTIMALCOLORS Example custom colormap for use with imagine
%  DCOLORMAP = OPTIMALCOLOR(INBINS) returns a double colormap array of size
%  (INBINS, 3). Use this template to implement you own custom colormaps.
%  Imagine will interpret all m-files in this folder as potential colormap-
%  generating functions an list them using the filename.

% -------------------------------------------------------------------------
% Process input
if ~nargin, iNBins = 256; end
iNBins = uint16(iNBins);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create look-up tables (pairs of x- and y-vectors) for the three colors
dX    = [0  0.5    1];
dYRed = [0;   1; 0.5];
dYGrn = [0;   1;   0];
dYBlu = [0.5; 1;   0];
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Interpolate and concatenate vectors to the final colormap
dXInt = linspace(0, 1, iNBins).^dGamma;
dRedInt = interp1(dX, dYRed, dXInt');
dGrnInt = interp1(dX, dYGrn, dXInt');
dBluInt = interp1(dX, dYBlu, dXInt');

dColormap = [dRedInt, dGrnInt, dBluInt];
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION OptimalColor
% =========================================================================