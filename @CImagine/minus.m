function minus(obj, iView)

% -------------------------------------------------------------------------
% Determine data source and image orientation for current view
if ~obj.isOn('2d')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Layer view: Each view has its own series
    iMappingInd = obj.iStartSeries + iView - 1;
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % 3D view: each series occupies 3 views (all 3 orientations)
    iMappingInd = obj.iStartSeries + ceil(iView./3) - 1;
end

iInd = setdiff(1:length(obj.cMapping), iMappingInd);
obj.cMapping = {obj.cMapping{iInd}};

% -------------------------------------------------------------------------
% Garbage collector: find unassigned data and delete it

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Identify used data
iDataInUse = [];
for iI = 1:length(obj.cMapping)
    iDataInUse = unique([iDataInUse; obj.cMapping{iI}(:)]);
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Delete unused data from structure
obj.SData = obj.SData(iDataInUse);
% -------------------------------------------------------------------------

obj.setViewMapping;
obj.draw;
obj.position;
obj.grid;
