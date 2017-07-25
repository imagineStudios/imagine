function dCoverage = getCoverage(obj, iDim)

iSize = size(obj.Img);
iSize = padarray(iSize, [0, 5 - length(iSize)], 1, 'post');

dCoverage = (iSize - 1).*obj.Res + obj.Origin;

if nargin > 1
    dCoverage = iCoverage(iDim);
end