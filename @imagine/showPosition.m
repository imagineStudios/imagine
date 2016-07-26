function showPosition(obj, sMode)

persistent iColor

% iColor = [];
if isempty(iColor)
    
%     dPattern = 0.9 + 0.2*rand(1, 17001);
%     dPattern = repmat(dPattern, [3 1]);
%     iColor = repmat(permute(obj.dFGCOLOR, [2 1]), [1 17001]).*dPattern;
%     iColor = uint8([iColor; 0.5*ones(1, 17001)]*255);
    
    dPattern = 1 - 0.7*rand(17001, 1);
    dBGImg = fBlend(3*obj.dFGCOLOR, dPattern, 'multiply', 0.5);
    dBGImg = permute(dBGImg, [3 1 2]);
    iColor = uint8([dBGImg; zeros(1, 17001) + 0.5].*255);
end

if strcmp(sMode, 'slice')
    dDIST = 8;
    sMARKER = 's';
else
    dDIST = 24;
    sMARKER = 'o';
end

for iView = 1:numel(obj.SView)
    
    SView = obj.SView(iView);
    
    if SView.iData
        
        dPos  = get(SView.hAxes, 'Position');
        
        if strcmp(sMode, 'slice')
            
            dYLim_mm = get(SView.hAxes, 'YLim');
            dXLim_mm = get(SView.hAxes, 'XLim');
            dYSize_px = dPos(4);
            dXSize_px = dPos(3);
            
            iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
            iN = size(obj.SData(SView.iData(1)).dImg, iDim(3));
            
            iNRows = min(floor(dYSize_px.*0.9./dDIST), iN);
            [iNRows, iNCols] = fOptiRows(iN, iNRows);
            
            dYData = dDIST.*( (0:iNRows - 1)' - (iNRows - 1)/2 );
            if strcmp(get(SView.hAxes, 'YDir'), 'normal')
                dYData = - dYData;
            end
            
            dYData = mean(dYLim_mm) + dYData.*diff(dYLim_mm)./dYSize_px;
            if ~mod(dYSize_px, 2), dYData = dYData + diff(dYLim_mm)./dYSize_px./2; end
            
            dXData = dDIST.*(iNCols + 1:-1:2) + 0.5;
            if strcmp(get(SView.hAxes, 'XDir'), 'normal')
                dXData = dXLim_mm(2) - dXData.*diff(dXLim_mm)./dXSize_px;
            else
                dXData = dXLim_mm(1) + dXData.*diff(dXLim_mm)./dXSize_px;
            end
            [dY, dX] = ndgrid(dYData, dXData);
            
            d3Lim_mm = obj.get3Lim(SView);
            iInd = getSliceInd(obj, d3Lim_mm, SView.iData(1), iDim);
        else
            
            dYLim_mm = get(SView.hAxes, 'YLim');
            dXLim_mm = get(SView.hAxes, 'XLim');
            dYSize_px = dPos(4);
            dXSize_px = dPos(3);
            
            iN = size(obj.SData(SView.iData(1)).dImg, 5);
            
            iNCols = min(floor(dXSize_px.*0.9./dDIST), iN);
            iNRows = ceil(iN./iNCols);
                        
            dXData = dDIST.*( (0:iNCols - 1)' - (iNCols - 1)/2 );
            if ~strcmp(get(SView.hAxes, 'XDir'), 'normal')
                dXData = - dXData;
            end
            dXData = mean(dXLim_mm) + dXData.*diff(dXLim_mm)./dXSize_px;
            if ~mod(dXSize_px, 2), dXData = dXData + diff(dXLim_mm)./dXSize_px./2; end
            
            
            dYData = dDIST.*(iNRows + 1:-1:2) + 0.5;
            if strcmp(get(SView.hAxes, 'YDir'), 'reverse')
                dYData = dYLim_mm(2) - dYData.*diff(dYLim_mm)./dYSize_px;
            else
                dYData = dYLim_mm(1) + dYData.*diff(dYLim_mm)./dYSize_px;
            end
            [dY, dX] = ndgrid(dYData, dXData);
            
            iInd = obj.SData(SView.iData(1)).dDrawCenter(5);
        end
        
        dY = dY(1:iN);
        dX = dX(1:iN);
        
        iCol = iColor(:,1:iN);
        iCol(:, iInd) = repmat(uint8([1; 1; 1; 0.8].*255), [1 length(iInd)]);
        
        set(SView.hScatter, 'XData', dX, 'YData', dY, 'Visible', 'on', 'SizeData', 9^2, 'Marker', sMARKER);
        try
            h = SView.hScatter.MarkerHandle;
            set(h, 'FaceColorBinding', 'interpolated', 'FaceColorData', iCol);
        catch
            
        end
        
        set(SView.hText(2, 1, :), 'Visible', 'off');
        set([obj.STooltip.hImg obj.STooltip.hText],  'Visible', 'off');
    end
end

stop(obj.STimers.hToolTip);
start(obj.STimers.hToolTip);


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


