function drawHistogram(obj, iView)

iSeries = obj.SView(iView).iData;

dYData = [0, obj.SData(iSeries).dHist, 0];

dXData = [obj.SData(iSeries).dHistCenter(1), obj.SData(iSeries).dHistCenter, obj.SData(iSeries).dHistCenter(end)];

dXLim = [dXData(1), dXData(end)];
% dXLim = obj.SData(iSeries).dWindowCenter + 0.5.*[-obj.SData(iSeries).dWindowWidth obj.SData(iSeries).dWindowWidth];

set(obj.SSidebar.hPatch, 'XData', dXData, 'YData', dYData);
set(obj.SSidebar.hAxes, 'XLim', dXLim, 'YLim', [0, prctile(dYData, 90)*2], 'YDir', 'normal', 'XDir', 'normal');