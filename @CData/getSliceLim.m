function d3Lim_px = getSliceLim(obj, dDrawCenter_xyzt, iDim)

dDrawCenter_data = abs(obj.B')*dDrawCenter_xyzt(1:3)';

if any(strcmp(obj.Parent.getDrawMode, {'min', 'max'}));
    dMipDepth = 10;
    d3Lim_mm = dDrawCenter_data(iDim) + 0.5.*[-dMipDepth dMipDepth];
else
    d3Lim_mm = [dDrawCenter_data(iDim), dDrawCenter_data(iDim)];
end

d3Lim_px = round((d3Lim_mm - obj.Origin(iDim))./obj.Res(iDim) + 1);
d3Lim_px = d3Lim_px(1):d3Lim_px(2);
d3Lim_px = d3Lim_px(d3Lim_px > 0 & d3Lim_px <= iGlobals.fSize(obj.Img, iDim));