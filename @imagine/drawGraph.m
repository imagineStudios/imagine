function drawGraph(obj)

if ~obj.iSidebarWidth, return, end

dX = get(obj.SView(obj.SAction.iView).hLine(1), 'XData');
dY = get(obj.SView(obj.SAction.iView).hLine(1), 'YData');

dDist = norm([diff(dX); diff(dY)]);
if dDist < 1.0, return, end % In case of a mis-click

iStartDim = obj.SData(obj.SView(obj.SAction.iView).iData).iDims(obj.SView(obj.SAction.iView).iDimInd, :);

iN = 1;
dMin = inf; dMax = -inf;
for iView = 1:numel(obj.SView)
    SView = obj.SView(iView);
    if all(iStartDim == obj.SData(SView.iData).iDims(SView.iDimInd, :));
        
        dImg = obj.getData(SView, SView.iData(1), 0);
        
        dRes = obj.SData(SView.iData).dRes(iStartDim(1:2));
        dOrigin = obj.SData(SView.iData).dOrigin(iStartDim(1:2));
        
        dX1 = (0:size(dImg, 2) - 1).*dRes(2) + dOrigin(2);
        dY1 = (0:size(dImg, 1) - 1).*dRes(1) + dOrigin(1);
        
        dAlpha = (0:min(dRes):dDist)./dDist;
        dXI = dX(1) + diff(dX).*dAlpha;
        dYI = dY(1) + diff(dY).*dAlpha;
        
        dData = interp2(dX1, dY1, dImg, dXI, dYI, 'linear', 0);
        
        dDataOut(iView) = fFWHM(dData).*min(dRes);
        
        
        set(obj.SSidebar.hLine(iN), 'XData', 0:length(dData) - 1, 'YData', dData, 'Visible', 'on');
        iN = iN + 1;
        
        dMin = min([dData, dMin]);
        dMax = max([dData, dMax]);
    end
end
set(obj.SSidebar.hLine(iN:end), 'Visible', 'off');
dDataOut = dDataOut(dDataOut ~=0);
assignin('base', 'temp', dDataOut);
evalin('base', 'a(end + 1,:) = temp;');
set(obj.SSidebar.hAxes, 'XLim', [0 length(dData) - 1], 'YLim', [dMin dMax], 'XDir', 'normal', 'YDir', 'normal');
set(obj.SSidebar.hImg, 'Visible', 'off');