function [iX, iY] = fLiveWireGetPath(iPX, iPY, iXS, iYS)
%FLIVEWIREGETPATH Traces the cheapest path from (IXS, IYS)^T through the
%pathmaps IPX, IPY back to the seed (where both, IPX and IPY are 0).
%
%   See also LIVEWIRE, FLIVEWIRECALCP, FLIVEWIREGETCOSTFCN.
%
%
%   Copyright 2013 Christian Würslin, University of Tübingen and University
%   of Stuttgart, Germany. Contact: christian.wuerslin@med.uni-tuebingen.de

iMAXPATH = 1000;

% -------------------------------------------------------------------------
% Initialize the variables
iPX  = int16(iPX);
iPY  = int16(iPY);
iXS = int16(iXS);
iYS = int16(iYS);

iX = zeros(iMAXPATH, 1, 'int16');
iY = zeros(iMAXPATH, 1, 'int16');

iLength = 1;
iX(iLength) = iXS;
iY(iLength) = iYS;
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% While not at the seed point: march back in the direction indicated by the
% path maps iPX (x-direction) and iPY (y-direction).
while (iPX(iYS, iXS) ~= 0) || (iPY(iYS, iXS) ~= 0) % We're not at the seed
    iXS = iXS + iPX(iYS, iXS);
    iYS = iYS + iPY(iYS, iXS);
    iLength = iLength + 1;
    iX(iLength) = iXS;
    iY(iLength) = iYS;
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% revert vectors (to make it a forward path) and don't return the seed point.
iX = iX(iLength - 1:-1:1);
iY = iY(iLength - 1:-1:1);
% -------------------------------------------------------------------------