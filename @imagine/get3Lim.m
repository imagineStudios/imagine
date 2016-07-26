function dZLim = get3Lim(obj, SView)

iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);

if any(strcmp(obj.getDrawMode, {'min', 'max'}));
    dMipDepth = obj.getSlider('Projection Depth');
else
    dMipDepth = 0;
end

dZLim = obj.SData(SView.iData(1)).dDrawCenter(iDim(3)) + 0.5.*[-dMipDepth dMipDepth];