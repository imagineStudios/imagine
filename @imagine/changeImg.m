function changeImg(obj, ~, iCnt)

% -------------------------------------------------------------------------
% Determine origin of callback and which dimension to work on
if isstruct(iCnt) || isobject(iCnt)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Mouse wheel callback: operate depending on current view
    iCnt = iCnt.VerticalScrollCount;
    if obj.SAction.lShift
        iDim(3) = 5;
    else
        hView = obj.getView;
        if isempty(hView), return, end
        if isempty(hView.hData), return, end
        iDim      = hView.hData(1).Dims(hView.iDimInd, :);
        dStepSize = hView.hData(1).Res(iDim(3));
    end
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Keyboard input (iCnt is numeric): work on the first view
    if isempty(obj.SView(1).iData), return, end
    iDim = obj.SData(obj.SView(1).iData(1)).iDims(obj.SView(1).iDimInd, :);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Loop over all views
for iI = 1:length(obj.hViews)
    if ~isempty(obj.hViews(iI).DrawCenter)
        d = obj.hViews(iI).DrawCenter(iDim(3)) + iCnt.*dStepSize;
        obj.hViews(iI).DrawCenter(iDim(3)) = d;
    end
end
% -------------------------------------------------------------------------


% -----------------------------------------------------------------
% Show a crosshair using the grids if in 3D mode
% if obj.isOn('2d')
%     if obj.dGrid ~= -1, obj.SAction.dGrid = obj.dGrid; end
%     obj.dGrid = -1;
%     obj.position;
%     obj.grid;
% end

% if iDim(3) == 5
%     obj.showPosition('time');
% else
%     if ~obj.isOn('2d')
%         obj.showPosition('slice');
%     end
% end

% -----------------------------------------------------------------


% -----------------------------------------------------------------
% Draw!
% notify(obj, 'viewImageChange');
% -----------------------------------------------------------------