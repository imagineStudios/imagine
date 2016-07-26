function dColormapImg = getColormapImg(csColormaps)

persistent dImg

% -------------------------------------------------------------------------
% On first startup, get preview of the installed colormaps
if isempty(dImg)
    dImg = zeros(length(csColormaps), 16, 3);
    for iI = 1:length(csColormaps)
        eval(['dLine = cmap_', csColormaps{iI}, '(16, 1);']);
        dImg(iI, :, :) = permute(dLine, [3, 1, 2]);
    end
end
% -------------------------------------------------------------------------

dColormapImg = dImg;
