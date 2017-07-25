function showSquare(obj)

iActiveView = obj(1).hParent.iActiveView;
for iI = 1:numel(obj)
    o = obj(iI);
    lIsActive = o.Ind == iActiveView;
    for iDimInd = 1:length(obj(iI).hA)
        hA = o.hA(iDimInd);
        dYLim_mm = get(hA, 'YLim');
        dXLim_mm = get(hA, 'XLim');
        dAxesPos = get(hA, 'Position');
        
        if strcmp(get(o.hA(iDimInd), 'YDir'), 'normal')
            dYData = dYLim_mm(2) - 10.*diff(dYLim_mm)./dAxesPos(4);
        else
            dYData = dYLim_mm(1) + 10.*diff(dYLim_mm)./dAxesPos(4);
        end
        
        if strcmp(get(o.hA(iDimInd), 'XDir'), 'normal')
            dXData = dXLim_mm(1) + 10.*diff(dXLim_mm)./dAxesPos(3);
        else
            dXData = dXLim_mm(2) - 10.*diff(dXLim_mm)./dAxesPos(3);
        end
        
        set(o.hS1(iDimInd), 'XData', dXData, 'YData', dYData, 'SizeData', 15.^2, 'Marker', 's');
    end
    set([o.hS1.MarkerHandle], 'FaceColorBinding', 'interpolated', 'FaceColorData', o.iRandColor(:, 1));
    if ~lIsActive
        
        set([o.hS1], 'MarkerEdgeColor', 'none');
    else
        %             set([o.hS.MarkerHandle], 'FaceColorBinding', 'interpolated', 'FaceColorData', zeros(4, 1, 'uint8'));
        set([o.hS1], 'MarkerEdgeColor', [0.5 0.5 0.5]);
    end
end