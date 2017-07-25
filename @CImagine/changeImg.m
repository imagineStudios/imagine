function changeImg(obj, ~, iCnt)

% -------------------------------------------------------------------------
% Determine origin of callback and which dimension to work on
if isstruct(iCnt) || isobject(iCnt)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Mouse wheel callback: operate depending on current view
    iCnt = iCnt.VerticalScrollCount;
    hView = obj.SAction.hView;
    iDimInd = obj.SAction.iDimInd;
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Keyboard input (iCnt is numeric): work on the first view
    hView = obj.hViews(1);
    iDimInd = 1;
end

if isempty(hView), return, end
if isempty(hView.hData), return, end

if obj.SAction.lShift
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Change Timepoint
    iDim = 4;
    dStepSize = 1;
    iCnt = sign(iCnt);
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Change z coordinate
    iDim = hView.hData(1).Dims(iDimInd, 3);
    dStepSize = obj.dMinRes(iDim);
%     dStepSize = hView.hData(1).Res(iDim);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Apply scrolling to all views
dDelta = zeros(1, 5);
dDelta(iDim) = iCnt.*dStepSize;
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

if iDim == 4
    obj.hViews.showTimePoint;
else
    obj.hViews.showSlicePosition;
end
% -----------------------------------------------------------------