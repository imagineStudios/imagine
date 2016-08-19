function iSize = getSize(obj)

iSize = size(obj.Img);
iSize = padarray(iSize, [0, 5 - length(iSize)], 'post');