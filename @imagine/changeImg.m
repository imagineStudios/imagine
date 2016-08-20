function changeImg(obj, ~, iCnt)

% -------------------------------------------------------------------------
% Determine origin of callback and which dimension to work on
if isstruct(iCnt) || isobject(iCnt)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Mouse wheel callback: operate depending on current view
    iCnt = iCnt.VerticalScrollCount;
    if obj.SAction.lShift
        iDim(3) = 4;
    else
        hView = obj.SAction.hView;
        if isempty(hView), return, end
        if isempty(hView.hData), return, end
        iDim      = hView.hData(1).Dims(obj.SAction.iDimInd, :);
        dStepSize = min(hView.hData(1).Res);
    end
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Keyboard input (iCnt is numeric): work on the first view
    if isempty(obj.SView(1).iData), return, end
    iDim = obj.SData(obj.SView(1).iData(1)).iDims(obj.SView(1).iDimInd, :);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Apply scrolling to all views
dDelta = zeros(1, 5);
dDelta(iDim(3)) = iCnt.*dStepSize;
obj.hViews.shift(dDelta);
% -------------------------------------------------------------------------


% -----------------------------------------------------------------
% Update the view contents
obj.hViews.draw;
if obj.isOn('3d')
%     if obj.dGrid ~= -1, obj.SAction.dGrid = obj.dGrid; end
%     obj.dGrid = -1;
    obj.hViews.position;
%     obj.grid;
end

% if iDim(3) == 5
%     obj.showPosition('time');
% else
%     if ~obj.isOn('3d')
%         obj.showPosition('slice');
%     end
% end
% -----------------------------------------------------------------