function [dDataOut, sName, sUnitFormat] = fMin(dData)

% -------------------------------------------------------------------------
% Prepare the outputs
sName = 'Min'; % Return a string of what values the function calculates
sUnitFormat = '';
dDataOut = min(dData(:));
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION fEvalLineFWHM
% =========================================================================