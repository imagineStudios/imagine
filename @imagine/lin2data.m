function [iInd, iDimInd] = line2data(obj, iInd)

% -------------------------------------------------------------------------
% Determine data source and image orientation for current view
if ~obj.isOn('2d')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Layer view: Each view has its own series
    iInd = iInd;
    iDimInd = 1;
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % 3D view: each series occupies 3 views (all 3 orientations)
    iDimInd = mod(iInd - 1, 3) + 1;
    iInd = ceil(iInd./3);
end