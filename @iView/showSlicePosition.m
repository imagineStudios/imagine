function showSlicePosition(obj)

% persistent iColor

% iColor = [];
% if isempty(iColor)
%     dPattern = 1 - 0.7*rand(17001, 1);
%     dBGImg = fBlend(3*obj(1).dColor, dPattern, 'multiply', 0.5);
%     dBGImg = permute(dBGImg, [3 1 2]);
%     iColor = uint8([dBGImg; zeros(1, 17001) + 0.5].*255);
% end

dDIST = 8;
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
            [iNRows, iNCols] = fOptiRows(iN, iNRows);
            
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
            
            set(o.hS(iDimInd), 'XData', dX, 'YData', dY, 'Visible', 'on', 'SizeData', 9^2, 'Marker', sMARKER);
            try
                h = o.hS(iDimInd).MarkerHandle;
                set(h, 'FaceColorBinding', 'interpolated', 'FaceColorData', iCol);
            catch
                
            end
            
            %         set(o.hText(2, 1, :), 'Visible', 'off');
            %         set([obj.STooltip.hImg obj.STooltip.hText],  'Visible', 'off');
        end
    end
end

% stop(obj.STimers.hToolTip);
% start(obj.STimers.hToolTip);


function [iNRows, iNCols] = fOptiRows(iN, iNMaxRows)


iNRows = iNMaxRows;
iNCols = ceil(iN./iNMaxRows);
if iNCols == 1, return, end

for iNRows = iNRows:-1:1
    if mod(iN, iNRows) == 0, break; end
end
if iNRows < 0.5.*iNMaxRows
    iNRows = iNMaxRows;
end

iNCols = ceil(iN./iNRows);


