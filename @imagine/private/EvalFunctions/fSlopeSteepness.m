function [dDataOut, sName, sUnitFormat] = fSlopeSteepness(dData)

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
dSlope = max(abs(diff(dData)));
dDataOut = dSlope.*iINTERPOLATIONFACTOR;
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION fEvalLineFWHM
% =========================================================================