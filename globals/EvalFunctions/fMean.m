function [dDataOut, sName, sUnitFormat] = fMean(dData)
%FEVALROIMEAN Example ROI evaluation function calculating mean and std.
%   Data is provided in struct SDATA containing fields sName and dData.
%   HTEXTS provides handles to uicontrol text elements in the imagine GUI
%   which can be used to ouput the results

sName = 'Mean';
sUnitFormat = '';
dDataOut = mean(dData);
% =========================================================================
% *** END OF FUNCTION fEvalROIMean
% =========================================================================