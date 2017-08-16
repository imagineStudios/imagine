function dCenter_xyz = getCenter(obj)

iSize_mno = iGlobals.fSize(obj.Img, 1:3);
dCenter_xyz = obj.mno2xyz(iSize_mno./2);
dCenter_xyz = ([dCenter_xyz(:)', 1, 1]);
