function dCenter = getCenter(obj)

dCenter = round((obj.getSize./2 - 1).*obj.Res + obj.Origin);
dCenter([4, 5]) = 1;
