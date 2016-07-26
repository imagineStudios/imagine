function [dDataOut, sName, sUnitFormat] = fCOV(dData)

sName = 'COV';
sUnitFormat = '';
dDataOut = std(dData)./mean(dData);
% =========================================================================
% *** END OF FUNCTION fEvalROIMean
% =========================================================================