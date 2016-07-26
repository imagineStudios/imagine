function iSliceInd = getSliceInd(obj, d3Lim_mm, iSeries, iDim)

d3Lim_px(1) = max(1, round(obj.phys2Pixel(d3Lim_mm(1), iSeries, iDim(3))));
d3Lim_px(2) = min(round(obj.phys2Pixel(d3Lim_mm(2), iSeries, iDim(3))), ...
    size(obj.SData(iSeries).dImg, iDim(3)));
iSliceInd = d3Lim_px(1):d3Lim_px(2);
