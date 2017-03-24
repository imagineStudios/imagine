function showTimePoint(obj)

dDIST = 12;
sMARKER = 'o';

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
            
            iN = o.hData(1).getSize(4);
            
            iNCols = min(floor(dXSize_px.*0.9./dDIST), iN);
            [iNCols, iNRows] = fOptiRows(iN, iNCols);
                        
            dXData = dDIST.*( (0:iNCols - 1)' - (iNCols - 1)/2 );
            if ~strcmp(get(hA, 'XDir'), 'normal')
                dXData = - dXData;
            end
            dXData = mean(dXLim_mm) + dXData.*diff(dXLim_mm)./dXSize_px;
            if ~mod(dXSize_px, 2), dXData = dXData + diff(dXLim_mm)./dXSize_px./2; end
            
            dYData = dDIST.*(iNRows + 1:-1:2) + 0.5;
            if strcmp(get(hA, 'YDir'), 'reverse')
                dYData = dYLim_mm(2) - dYData.*diff(dYLim_mm)./dYSize_px;
            else
                dYData = dYLim_mm(1) + dYData.*diff(dYLim_mm)./dYSize_px;
            end
            [dX, dY] = ndgrid(dXData, dYData);
            
            iInd = o.DrawCenter(4);
            
            dY = dY(1:iN);
            dX = dX(1:iN);
            
            iCol = o.iRandColor(:,1:iN);
            iCol(:, iInd) = repmat(uint8([1; 1; 1; 0.8].*255), [1 length(iInd)]);
            
            set(o.hS2(iDimInd), 'XData', dX, 'YData', dY, 'Visible', 'on', 'SizeData', 9^2, 'Marker', sMARKER, 'MarkerEdgeColor', 'none');
            try
                h = o.hS2(iDimInd).MarkerHandle;
                set(h, 'FaceColorBinding', 'interpolated', 'FaceColorData', iCol);
            catch
                
            end
            
        end
    end
end

stop(obj(1).hParent.STimers.hToolTip);
start(obj(1).hParent.STimers.hToolTip);