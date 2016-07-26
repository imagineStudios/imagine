function [dDataOut, sName, sUnitFormat] = fFWHM(dData)
%FEVALLINEFWHM Example line evaluation function calculating the FWHM.
%   Data is provided in DDATA. SSELECTIONTYPE represents imagine's slection
%   type (modifier keys or mouse buttons used) to enable different
%   behaviour of the calculations (e.g. avaraging).

iINTERPOLATIONFACTOR = 10; % For a more precise calculation ot the FWHM

% -------------------------------------------------------------------------
% Prepare the outputs
sName = 'FWHM'; % Return a string of what values the function calculates
sUnitFormat = '%s';   % Displays the pixel spacing since the FWHM is a distance
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Calculate FWHM
iBins = (length(dData) - 1).*iINTERPOLATIONFACTOR + 1;
dData = interp1(dData, linspace(1, length(dData), iBins), 'pchip');

[dMax, iMaxPos] = max(dData);
dMin = min(dData);
dDiff5 = dData(iMaxPos:-1:1) - 0.5*(dMax + dMin);
iLowerHalfPos = iMaxPos - find(dDiff5 <= 0, 1, 'first') + 1;
dDiff5 = dData(iMaxPos:end) - 0.5*(dMax + dMin);
iUpperHalfPos = find(dDiff5 <= 0, 1, 'first') + iMaxPos - 1;
dFWHM = double(iUpperHalfPos - iLowerHalfPos);
if isempty(dFWHM), dFWHM = nan; end
dDataOut = dFWHM./iINTERPOLATIONFACTOR;
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION fEvalLineFWHM
% =========================================================================