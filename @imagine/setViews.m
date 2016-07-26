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
iNExistingViews = numel(obj.SView);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Determine the resulting line colormap
dColors = lines(iNViews);
% -------------------------------------------------------------------------

if iNViews < iNExistingViews
    
    % ---------------------------------------------------------------------
    % Delete the obsolete GUI elements
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete the view axes and implicitely it's children
    obj.SView = obj.SView(:);
    for iI = iNViews + 1:iNExistingViews
        delete(obj.SView(iI).hAxes); % Delete excess views
    end
    obj.SView = obj.SView(1:iNViews); % Remove exess handles    
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete the lines in the sidebar
    delete(obj.SSidebar.hLine(iNViews + 1:end));
    obj.SSidebar.hLine = obj.SSidebar.hLine(1:iNViews);
    % ---------------------------------------------------------------------

elseif iNViews > iNExistingViews
    % ---------------------------------------------------------------------
    % Create the additional views
    for iI = iNExistingViews + 1:iNViews
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % View axes and its children
        obj.SView(iI).hAxes = axes(...
            'Parent'            , obj.hF, ...
            'Layer'             , 'top', ...
            'Units'             , 'pixels', ...
            'Color'             , 'k', ...
            'FontSize'          , 12, ...
            'XTickMode'         , 'manual', ...
            'YTickMode'         , 'manual', ...
            'XColor'            , [0.5 0.5 0.5], ...
            'YColor'            , [0.5 0.5 0.5], ...
            'XTickLabelMode'    , 'manual', ...
            'YTickLabelMode'    , 'manual', ...
            'XAxisLocation'     , 'top', ...
            'YDir'              , 'reverse', ...
            'Box'               , 'on', ...
            'HitTest'           , 'on', ...
            'XGrid'             , 'off', ...
            'YGrid'             , 'off', ...
            'XMinorGrid'        , 'off', ...
            'YMinorGrid'        , 'off');
        hold on
        
        try set(obj.SView(iI).hAxes, 'YTickLabelRotation', 90); end
        
        obj.SView(iI).hImg      = [];
        obj.SView(iI).hQuiver   = [];
        
        obj.SView(iI).hLine     = [];
        obj.SView(iI).hScatter  = [];
        obj.SView(iI).hText     = [];
        
        obj.SView(iI).iInd = iI;
        obj.SView(iI).iData = [];
        obj.SView(iI).iDimInd = 1;
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % The line in the sidebar
        obj.SSidebar.hLine(iI) = line(0, 0, ...
            'Parent'                , obj.SSidebar.hAxes, ...
            'Color'                 , dColors(iI,:), ...
            'Visible'               , 'off');
        
    end
end

obj.setViewMapping;

uistack([obj.SView.hAxes], 'bottom');

% Flip the representation in the handles array compared to the screen ordering to enable linear indexing
obj.SView = reshape(obj.SView, iCols, iRows); 
if ~obj.isOn('2d'), obj.iViews = [iCols, iRows]; end

if strcmp(get(obj.hF, 'Visible'), 'on')
    obj.resize(0);
    obj.draw;
end