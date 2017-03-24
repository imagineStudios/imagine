function [iNRows, iNCols] = fOptiRows(iN, iNMaxRows)

iNRows = iNMaxRows;
iNCols = ceil(iN./iNMaxRows);
if iNCols == 1, return, end

for iNRows = iNRows:-1:1
    if mod(iN, iNRows) == 0, break; end
end
if iNRows < 0.5.*iNMaxRows
    iNRows = iNMaxRows;
end

iNCols = ceil(iN./iNRows);