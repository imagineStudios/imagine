function dZLim = get3Lim(obj, iDim)

if any(strcmp(obj.hParent.getDrawMode, {'min', 'max'}));
    dMipDepth = obj.hParent.getSlider('Projection Depth');
    dZLim = obj.DrawCenter(iDim(3)) + 0.5.*[-dMipDepth dMipDepth];
else
    dZLim = [obj.DrawCenter(iDim(3)), obj.DrawCenter(iDim(3))];
end

