function dColormap = InvGray(iNBins, dGamma)
%LOGGRAY Example custom colormap for use with imagine
%  DCOLORMAP = LOGGRAY(INBINS) returns a double colormap array of size
%  (INBINS, 3). Use this template to implement you own custom colormaps.
%  Imagine will interpret all m-files in this folder as potential colormap-
%  generating functions an list them using the filename.

% -------------------------------------------------------------------------
% Process input
if ~nargin, iNBins = 256; end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create look-up tables (pairs of x- and y-vectors) for the three colors
dColormap = linspace(0, 1, iNBins).^dGamma;
dColormap = repmat(1 - dColormap', [1 3]);
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION LogGray
% =========================================================================