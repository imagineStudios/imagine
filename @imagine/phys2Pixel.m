function dCoord_px = phys2Pixel(obj, dCoord_mm, iSeries, iDims)
%PHYS2PIXEL transforms from physical corrdinates to pixels

dCoord_px = (dCoord_mm - obj.SData(iSeries).dOrigin(iDims))...
            ./obj.SData(iSeries).dRes(iDims) + 1;