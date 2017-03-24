function iSize = getSize(obj, iDim)

iSize = size(obj.Img);
iSize = padarray(iSize, [0, 5 - length(iSize)], 1, 'post');

if nargin > 1
    iSize = iSize(iDim);
end