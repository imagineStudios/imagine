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
        SView = obj.getView;
        if isempty(SView.iData), return, end
        if ~SView.iData, return, end
        iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
    end
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Keyboard input (iCnt is numeric): work on the first view
    if isempty(obj.SView(1).iData), return, end
    iDim = obj.SData(obj.SView(1).iData(1)).iDims(obj.SView(1).iDimInd, :);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Loop over all data
for iSeries = 1:length(obj.SData)
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Calculate new image index and make sure it's not out of bounds
    dRes = obj.SData(iSeries).dRes;
    dSize = fSize(obj.SData(iSeries).dImg, 1:5);
    
    iNewImgInd = obj.SData(iSeries).dDrawCenter(iDim(3)) + iCnt.*dRes(iDim(3));
    
    dMin = obj.SData(iSeries).dOrigin(iDim(3));
    dMax = dMin + dRes(iDim(3)).*(dSize(iDim(3)) - 1);
    
    iNewImgInd = min(max(iNewImgInd, dMin), dMax);
    obj.SData(iSeries).dDrawCenter(iDim(3)) = iNewImgInd;
end
% -------------------------------------------------------------------------


% -----------------------------------------------------------------
% Show a crosshair using the grids if in 3D mode
if obj.isOn('2d')
    if obj.dGrid ~= -1, obj.SAction.dGrid = obj.dGrid; end
    obj.dGrid = -1;
    obj.position;
    obj.grid;
end

if iDim(3) == 5
    obj.showPosition('time');
else
%     if ~obj.isOn('2d')
        obj.showPosition('slice');
%     end
end

% -----------------------------------------------------------------


% -----------------------------------------------------------------
% Draw!
obj.draw;
% -----------------------------------------------------------------