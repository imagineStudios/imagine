function iSize = fSize(xMat, iDims)
%fSIZE determines size of matrix along specified dimensions
%   iSIZE = fSIZE(xMAT, iDIMS) determis the size iSIZE of xMAT along the
%   dimenstions iDIMS. Like standard SIZE, but allows for the specification
%   of multiple dimensions in arbitrary order.
%
% See also size

if nargin < 2, iDims = 1:ndims(xMat); end

iSize = zeros(1, length(iDims));
for iI = 1:length(iDims)
    iSize(iI) = size(xMat, iDims(iI));
end