function dColormap = Gray(iNBins, dGamma)

dX = linspace(0, 1, iNBins);
dX = dX.^dGamma;

dColormap = repmat(dX', [1, 3]);