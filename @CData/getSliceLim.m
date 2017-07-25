function d3Lim_px = getSliceLim(obj, dDrawCenter, iDim)

if any(strcmp(obj.Parent.getDrawMode, {'min', 'max'}));
    dMipDepth = 10;%obj.Parent.getSlider('Projection Depth');
    d3Lim_mm = dDrawCenter(iDim(3)) + 0.5.*[-dMipDepth dMipDepth];
else
    d3Lim_mm = [dDrawCenter(iDim(3)), dDrawCenter(iDim(3))];
end

d3Lim_px = round((d3Lim_mm - obj.Origin(iDim(3)))./obj.Res(iDim(3)) + 1);
d3Lim_px = d3Lim_px(1):d3Lim_px(2);
d3Lim_px = d3Lim_px(d3Lim_px > 0 & d3Lim_px <= fSize(obj.Img, iDim(3)));