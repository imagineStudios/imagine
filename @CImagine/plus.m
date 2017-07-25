function plus(obj, varargin)
%PLUS Add a new series to the data structure
% PLUS(OBJ, DIMG, VARARGIN) Adds the data in structure SNEWDATA to the
% GUI's data structure. Depending on the dimensions of SNEWDATA.dIMG, it
% decides wether the data is to be interpretet as RGB of scalar data. It is
% treated as RGB, if size(SNEWDATA.dImg, 3) == 3. If not 3 but greater than
% 1, the third dimension is treated as the 3rd dimension.


% -------------------------------------------------------------------------
% Prepare template data structure for new entry
iDataInd = length(obj.hData) + 1;
obj.hData(iDataInd) = iData(obj, iDataInd, varargin{:});
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Determine to which view the new data has to be added. If no view supplied
% explicitely, add a new view
iCurrentViews = 0;
for iI = 1:length(obj.hData)
    iCurrentViews = max([iCurrentViews, obj.hData(iI).iViews]);
end

hP = inputParser;
hP.KeepUnmatched = true;
hValidFcn = @(x) validateattributes(x, {'numeric'}, {'vector', 'positive'});
hP.addParameter('View', iCurrentViews + 1, hValidFcn);
hP.parse(varargin{2:end});
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Add the data to the view mapping and update
obj.hData(iDataInd).iViews = hP.Results.View;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Update global drawing parameters
dAllRes = cell2mat({obj.hData.Res}');
obj.dMinRes = min(dAllRes, [], 1);
% -------------------------------------------------------------------------