function showSquare(obj)

for iI = 1:numel(obj)
    o = obj(iI);
    if ~isempty(o.hData)
        for iDimInd = 1:length(obj(iI).hA)
            iDim = o.hData(1).Dims(iDimInd, :);
            hA = o.hA(iDimInd);
            dYLim_mm = get(hA, 'YLim');
            dXLim_mm = get(hA, 'XLim');
            dAxesPos = get(hA, 'Position');
            
            if obj(iI).hData(1).Invert(iDim(1))
                dYData = dYLim_mm(2) - 10.*diff(dYLim_mm)./dAxesPos(4);
            else
                dYData = dYLim_mm(1) + 10.*diff(dYLim_mm)./dAxesPos(4);
            end
            
            if obj(iI).hData(1).Invert(iDim(2))
                dXData = dXLim_mm(2) - 10.*diff(dXLim_mm)./dAxesPos(3);
            else
                dXData = dXLim_mm(1) + 10.*diff(dXLim_mm)./dAxesPos(3);
            end
            
            set(o.hS(iDimInd), 'XData', dXData, 'YData', dYData, 'SizeData', 200);
        end
        set([o.hS.MarkerHandle], 'FaceColorBinding', 'interpolated', 'FaceColorData', o.iRandColor(:, 1));
    else
        set(o.hS, 'Visible', 'off');
    end
end