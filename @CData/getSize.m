function iSize_xyz = getSize(obj)

iSize = +iGlobals.fSize(obj.Img, 1:3);

iSize_xyz = obj.B*iSize(:);