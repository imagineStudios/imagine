function setViews(obj, iCols, iRows)

% -------------------------------------------------------------------------
% Determine new number of views
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
iNViews = iRows*iCols;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Existing number of views
iNExistingViews = numel(obj.hViews);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Determine the resulting line colormap
% dColors = lines(iNViews);
% -------------------------------------------------------------------------

if iNViews < iNExistingViews
    
    % ---------------------------------------------------------------------
    % Delete the obsolete GUI elements
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete the view axes and implicitely it's children
    obj.hViews = obj.hViews(:);
    delete(obj.hViews(iNViews + 1:iNExistingViews));
    obj.hViews = obj.hViews(1:iNViews); % Remove exess handles    
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete the lines in the sidebar
%     delete(obj.SSidebar.hLine(iNViews + 1:end));
%     obj.SSidebar.hLine = obj.SSidebar.hLine(1:iNViews);
    % ---------------------------------------------------------------------

elseif iNViews > iNExistingViews
    % ---------------------------------------------------------------------
    % Create the additional views
    for iI = iNExistingViews + 1:iNViews
        
        if iI > length(obj.ViewMapping)
            obj.ViewMapping{iI} = [];
        end
        
        obj.hViews(iI) = iView(obj, iI);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % The line in the sidebar
%         obj.SSidebar.hLine(iI) = line(0, 0, ...
%             'Parent'                , obj.SSidebar.hAxes, ...
%             'Color'                 , dColors(iI,:), ...
%             'Visible'               , 'off');
        
        
    end
end

% obj.setViewMapping;

% obj.ViewMapping = obj.ViewMapping; % This should trigger the update in the views

% Flip the representation in the handles array compared to the screen ordering to enable linear indexing
obj.hViews = reshape(obj.hViews, iCols, iRows); 
% if ~obj.isOn('2d'), obj.iViews = [iCols, iRows]; end

if strcmp(get(obj.hF, 'Visible'), 'on')
    obj.resize(0); % Assign correct positioning to all views
    obj.hViews.draw; 
end