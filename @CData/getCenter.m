function dCenter = getCenter(obj)

iSize = obj.getSize;
dCenter = round((iSize(1:4)./2 - 1).*obj.Res + obj.Origin);
dCenter([4, 5]) = 1;
