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
obj.hData(iDataInd) = iData(obj, varargin{:});
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Determine to which view the new data has to be added
iCurrentViews = length(obj.ViewMapping);

hP = inputParser;
hP.KeepUnmatched = true;
hValidFcn = @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'});
hP.addParameter('View', iCurrentViews + 1, hValidFcn);
hP.parse(varargin{2:end});
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Add the data to the view mapping and update
% The view class listen to changes in cViewMapping
for iView = 1:length(hP.Results.View)
    if length(obj.ViewMapping) >= iView
        obj.ViewMapping{iView} = [obj.ViewMapping{iView}, iDataInd];
    else
        obj.ViewMapping{iView} = iDataInd;
    end
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Update the views
% if strcmp(get(obj.hF, 'Visible'), 'on')
%     obj.setViewMapping;
% end
% -------------------------------------------------------------------------