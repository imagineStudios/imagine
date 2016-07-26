function [dDataOut, sName, sUnitFormat] = fSlopeSteepness2(dData)

iINTERPOLATIONFACTOR = 10;

% -------------------------------------------------------------------------
% Prepare the outputs
sName = 'Slope'; % Return a string of what values the function calculates
sUnitFormat = ' 1/%s';
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Calculate Slope Steepness
iBins = (length(dData) - 1).*iINTERPOLATIONFACTOR + 1;
dData = interp1(dData, linspace(1, length(dData), iBins), 'pchip');
% figure, hist(dData);
% figure, plot(dData);
[dSlope1, iPos1] = max(diff(dData));
[dSlope2, iPos2] = min(diff(dData));
dSlope = (dSlope1 - dSlope2)./2;
dDataOut = dSlope.*iINTERPOLATIONFACTOR;
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION fEvalLineFWHM
% =========================================================================