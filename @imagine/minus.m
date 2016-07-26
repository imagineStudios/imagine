function minus(obj, iMappingInd)

% -------------------------------------------------------------------------
% Delete entry from the mapping table
lMask = true(size(obj.iMapping, 1), 1);
lMask(iMappingInd) = false;
obj.iMapping = obj.iMapping(lMask, :);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Garbage collector: find unassigned data and delete it

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Identify used data
iData = 1:length(obj.SData);
iDataInUse = unique(obj.iMapping(:));

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Delete unused data from structure
obj.SData = obj.SData(iDataInUse);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Compensate the data reordering in the mapping table
iNewDataInd = iData(iDataInUse);
for iI = 1:numel(obj.iMapping)
    obj.iMapping(iI) = find(iNewDataInd == obj.iMapping(iI));
end
% -------------------------------------------------------------------------

obj.setViewMapping;
obj.draw;
obj.position;
obj.grid;
