function drawFocus(obj, dCoord_mm)

if ~obj.iSidebarWidth, return, end

SView = obj.getView;
dXData = get(SView.hAxes, 'XData');
dYData = get(SView.hAxes, 'YData');
if all(dCoord_mm(1:2) > [dYData(1) dXData(1)]) && all(dCoord_mm(1:2) <= [dYData(end) dXData(end)])
    
    dImg = get(SView.hImg, 'CData');
    
    dAxesPos = get(obj.SAxes.hSidebar, 'Position');
    dAxesSizePx = dAxesPos([4, 3]); % Axes size in pixels
    
    dZoom     = obj.SData(SView.iData).dZoom.*get(obj.SScatters.hSlider(6), 'XData');
    dDelta_mm = dAxesSizePx./2./dZoom.*min(obj.SData(SView.iData).dRes([1 2 4]));
    set(obj.SImgs.hSidebar, 'CData', dImg, 'XData', dXData, 'YData', dYData, 'Visible', 'on');
    set(obj.SAxes.hSidebar, ...
        'XLim', dCoord_mm(2) + [-dDelta_mm(2) dDelta_mm(2)], ...
        'YLim', dCoord_mm(1) + [-dDelta_mm(1) dDelta_mm(1)], ...
        'XDir', get(SView.hAxes, 'XDir'), ...
        'YDir', get(SView.hAxes, 'YDir'), ...
        'XTick', dCoord_mm(2), 'YTick', dCoord_mm(1), ...
        'XTickLabel', {}, 'YTickLabel', {});
    
    set(obj.SLines.hEval, 'Visible', 'off');
    
else
    set(obj.SImgs.hSidebar, 'CData', permute(obj.dBGCOLOR/2, [1 3 2]));
    set(obj.SAxes.hSidebar, 'XLim', [0.5 1.5], 'YLim', [0.5 1.5]);
end

