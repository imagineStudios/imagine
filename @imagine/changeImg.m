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
        dStepSize = hView.hData(1).Res(iDim(3));
    end
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Keyboard input (iCnt is numeric): work on the first view
    if isempty(obj.hViews(1).hData), return, end
    iDim = obj.hViews(1).hData(1).Dims(1, :);
    dStepSize = obj.hViews(1).hData(1).Res(iDim(3));
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
obj.draw;
if obj.isOn('3d')
%     if obj.dGrid ~= -1, obj.SAction.dGrid = obj.dGrid; end
    obj.dGrid = -1;
    obj.hViews.position;
    obj.hViews.grid;
end
obj.hViews.showSlicePosition;

% if iDim(3) == 5
%     obj.showPosition('time');
% else
%     if ~obj.isOn('3d')
%         obj.showPosition('slice');
%     end
% end
% -----------------------------------------------------------------