function setViews(obj, iCols, iRows)

l3D = obj.isOn('3d');
iAxesPerView = double(l3D) * 2 + 1;

% -------------------------------------------------------------------------
% Determine new number of views

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Existing number of views
iNExistingViews = numel(obj.hViews);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Desired number of views
if nargin < 3
    if isscalar(iCols)
        iRows = iCols;
    else
        iRows = iCols(2);
        iCols = iCols(1);
    end
end
iNViews = ceil(iRows*iCols/iAxesPerView);
obj.iAxes = [iCols, iRows];
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Create new or delete obsolete views
obj.hViews = obj.hViews(:);
if iNViews < iNExistingViews
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete the view axes and implicitely it's children
    delete(obj.hViews(iNViews + 1:iNExistingViews));
    obj.hViews = obj.hViews(1:iNViews); % Remove invalid handles    
    
elseif iNViews > iNExistingViews
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Create the new views
    for iI = iNExistingViews + 1:iNViews
        obj.hViews(iI) = CView(obj, iI, obj.isOn('3d'));
    end
end
% -------------------------------------------------------------------------

obj.hViews.setMode(l3D);
obj.hViews.updateData;
obj.draw;

if strcmp(get(obj.hF, 'Visible'), 'on')
    obj.resize(0); % Assign correct positioning to all views
end