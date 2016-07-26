function dCoord_mm = pixel2Phys(obj, dCoord_px, iSeries, iDims)
%PHYS2PIXEL transforms from physical corrdinates to pixels

dRes = obj.SData(iSeries).dRes(iDims);
dOrigin_mm = obj.SData(iSeries).dOrigin(iDims);

dCoord_mm = (dCoord_px - 1).*dRes + dOrigin_mm;