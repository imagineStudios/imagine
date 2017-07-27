function showSlicePosition(obj)

dDIST = 6;
sMARKER = 's';

for iI = 1:numel(obj)
    
    o = obj(iI);
    
    if ~isempty(o.hData)
        
        for iDimInd = 1:length(o.hA)
            
            hA = o.hA(iDimInd);
            
            dPos  = get(hA, 'Position');
            dYLim_mm = get(hA, 'YLim');
            dXLim_mm = get(hA, 'XLim');
            dYSize_px = dPos(4);
            dXSize_px = dPos(3);
            
            iDim = o.hData(1).Dims(iDimInd, :);
            dSize = o.hData(1).getSize;
            iN = dSize(iDim(3));
            
            iNRows = min(floor(dYSize_px.*0.9./dDIST), iN);
            [iNRows, iNCols] = iGlobals.fOptiRows(iN, iNRows);
            
            dYData = dDIST.*( (0:iNRows - 1)' - (iNRows - 1)/2 );
            if strcmp(get(hA, 'YDir'), 'normal')
                dYData = - dYData;
            end
            
            dYData = mean(dYLim_mm) + dYData.*diff(dYLim_mm)./dYSize_px;
            if ~mod(dYSize_px, 2), dYData = dYData + diff(dYLim_mm)./dYSize_px./2; end
            
            dXData = dDIST.*(iNCols + 1:-1:2) + 0.5;
            if strcmp(get(hA, 'XDir'), 'normal')
                dXData = dXLim_mm(2) - dXData.*diff(dXLim_mm)./dXSize_px;
            else
                dXData = dXLim_mm(1) + dXData.*diff(dXLim_mm)./dXSize_px;
            end
            [dY, dX] = ndgrid(dYData, dXData);
            
            iInd = o.hData(1).getSliceLim(o.DrawCenter, iDim);
            
            dY = dY(1:iN);
            dX = dX(1:iN);
            
            iCol = o.iRandColor(:,1:iN);
            iCol(:, iInd) = repmat(uint8([1; 1; 1; 0.8].*255), [1 length(iInd)]);
            
            set(o.hS2(iDimInd), 'XData', dX, 'YData', dY, 'Visible', 'on', 'SizeData', (dDIST + 1)^2, 'Marker', sMARKER, 'MarkerEdgeColor', 'none');
            try
                h = o.hS2(iDimInd).MarkerHandle;
                set(h, 'FaceColorBinding', 'interpolated', 'FaceColorData', iCol);
            catch
                
            end
        end
    end
end

% stop(obj(1).hParent.STimers.hToolTip);
% start(obj(1).hParent.STimers.hToolTip);