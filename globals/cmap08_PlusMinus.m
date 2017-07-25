function dColormap = PlusMinus(iNBins, dGamma)
%OPTIMALCOLORS Example custom colormap for use with imagine
%  DCOLORMAP = OPTIMALCOLOR(INBINS) returns a double colormap array of size
%  (INBINS, 3). Use this template to implement you own custom colormaps.
%  Imagine will interpret all m-files in this folder as potential colormap-
%  generating functions an list them using the filename.

dLUT = [ ...
    94    79   162
    50   136   189
   102   194   165
   171   221   164
   230   245   152
   255   255   191
   254   224   139
   253   174    97
   244   109    67
   213    62    79
   158     1    66  ] / 255;

dX = linspace(0, 1, iNBins).^dGamma;
dX = dX.*(length(dLUT) - 1) + 1;

dColormap = interp1(dLUT, dX);

