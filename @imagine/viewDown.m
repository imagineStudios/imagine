function viewDown(obj, ~, ~)

% -------------------------------------------------------------------------
% Make sure we're really over a non-empty view
hView = obj.SAction.hView;
if isempty(hView), return, end

obj.contextMenu(0);
if isempty(hView.hData)
    return
end
% -------------------------------------------------------------------------

% set([obj.SView.hScatter], 'Visible', 'off'); % Make sure the position display is hidden

% -------------------------------------------------------------------------
% Save some info about button down event

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Properties of the axes and imagine object
obj.SAction.iPos             = get(obj.hF, 'CurrentPoint');
obj.SAction.sSelectionType   = get(obj.hF, 'SelectionType');
obj.SAction.lMoved           = false;
if obj.dGrid ~= -1, obj.SAction.dGrid = obj.dGrid; end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Properties of the starting view
obj.SAction.dViewStartPos = obj.SAction.hView.getCurrentPoint(obj.SAction.iDimInd);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Backup the data properties
% obj.SAction.dDrawCenter = hView.DrawCenter;
obj.hViews.backup;
% obj.SAction.dWindowCenter = [obj.SData.dWindowCenter];
% obj.SAction.dWindowWidth  = [obj.SData.dWindowWidth];
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Tool-specific stuff
switch obj.getTool
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    case 'cursor'
%         obj.draw; % Make sure, the uninterpolated data is shown (expands beyond view bounds)
%         stop(obj.STimers.hDrawFancy); % Prevent interpolation
        
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Swap: Use a preview of the start axis to visualize the data exchange
    case 'swap'
        dImg = get(obj.SView(obj.SAction.iView).hImg, 'CData');
        if isempty(dImg), dImg = zeros(1, 1, 3); end
        set(obj.SImgs.hUtil, 'CData', dImg, 'AlphaData', 0.5, 'UserData', 3);
        set(obj.SAxes.hUtil, 'XLim', [0.5 size(dImg, 2) + 0.5], 'YLim', [0.5, size(dImg, 1) + 0.5]);
        dSize = [diff(get(obj.SAxes.hUtil, 'XLim')), diff(get(obj.SAxes.hUtil, 'YLim'))]/2;
        dPos = get(obj.hF, 'CurrentPoint');
        set(obj.SAxes.hUtil, 'Position', [dPos - dSize/2, dSize]);
        drawnow expose
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Activate the callbacks for drag operations
set(obj.hF, 'WindowButtonMotionFcn', @obj.viewDrag, 'WindowBUttonUpFcn', @obj.viewUp);
% -------------------------------------------------------------------------