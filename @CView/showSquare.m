function showSquare(obj)

iActiveView = obj(1).hParent.iActiveView;
for iI = 1:numel(obj)
    hView = obj(iI);
    lIsActive = hView.Ind == iActiveView;
    for iAxesInd = 1:length(obj(iI).hA)
        hA = hView.hA(iAxesInd);
        dYLim_mm = get(hA, 'YLim');
        dXLim_mm = get(hA, 'XLim');
        dAxesPos = get(hA, 'Position');
        
        if strcmp(get(hView.hA(iAxesInd), 'YDir'), 'normal')
            dYData = dYLim_mm(2) - 14.*diff(dYLim_mm)./dAxesPos(4);
        else
            dYData = dYLim_mm(1) + 14.*diff(dYLim_mm)./dAxesPos(4);
        end
        
        if strcmp(get(hView.hA(iAxesInd), 'XDir'), 'normal')
            dXData = dXLim_mm(1) + 14.*diff(dXLim_mm)./dAxesPos(3);
        else
            dXData = dXLim_mm(2) - 14.*diff(dXLim_mm)./dAxesPos(3);
        end
        
        set(hView.hS1(iAxesInd), 'XData', dXData, 'YData', dYData, 'SizeData', 15.^2, 'Marker', 's');
    end
    set([hView.hS1.MarkerHandle], 'FaceColorBinding', 'interpolated', 'FaceColorData', hView.iRandColor(:, 1));
    if ~lIsActive
        
        set([hView.hS1], 'MarkerEdgeColor', 'none');
    else
        %             set([o.hS.MarkerHandle], 'FaceColorBinding', 'interpolated', 'FaceColorData', zeros(4, 1, 'uint8'));
        set([hView.hS1], 'MarkerEdgeColor', [0.5 0.5 0.5]);
    end
end