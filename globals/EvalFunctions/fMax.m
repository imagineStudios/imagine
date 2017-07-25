function [dDataOut, sName, sUnitFormat] = fMax(dData)

% -------------------------------------------------------------------------
% Prepare the outputs
sName = 'Max'; % Return a string of what values the function calculates
sUnitFormat = '';
dDataOut = max(dData(:));
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION fEvalLineFWHM
% =========================================================================