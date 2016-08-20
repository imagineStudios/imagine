function mouseMove(obj, ~, ~)

persistent dFleur
if isempty(dFleur), dFleur = fGetFleur; end

% Set default mouse pointer
set(obj.hF, 'Pointer', 'Arrow', 'WindowButtonDownFcn', @obj.contextMenu);

% Get current object
hOver = hittest;

% -------------------------------------------------------------------------
% Check if over an icon (button)
iIcon = find(obj.SImgs.hIcons == hOver);
if ~isempty(iIcon)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Over icon, show tooltip
    sText = obj.SMenu(iIcon).Tooltip;
    sAccelerator = obj.SMenu(iIcon).Accelerator;
    if ~isempty(sAccelerator)
        iModifier = bitget(obj.SMenu(iIcon).Modifier, 1:8);
        if iModifier(3), sAccelerator = sprintf('Alt+%s', sAccelerator); end
        if iModifier(2), sAccelerator = sprintf('Ctl+%s', sAccelerator); end
        if iModifier(1), sAccelerator = sprintf('Shift+%s', sAccelerator); end
        sText = sprintf('%s [%s]', sText, sAccelerator);
    end
    obj.tooltip(sText);
    
    set(obj.hF, 'WindowButtonDownFcn', @obj.iconDown);
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Check if over a slider
obj.SAction.iSlider = find(hOver == [obj.SSliders.hAxes]);
if ~isempty(obj.SAction.iSlider)
    set(obj.hF, 'Pointer', 'left');
    set(obj.hF, 'WindowButtonDownFcn', @obj.sliderDown);
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% If over the tooltip, move it out of the way
if obj.STooltip.hImg == hOver || obj.STooltip.hText == hOver
    
    dTooltipPos = get(obj.STooltip.hAxes, 'Position');
    dFigureSize = get(obj.hF, 'Position');
    dNormalHeight = 0.618.*(dFigureSize(4) - 2.*obj.iIconSize) - dTooltipPos(4)/2;
    
    if dTooltipPos(2) <= dNormalHeight
        dHeight = fExpAnimation(10, dTooltipPos(2), dTooltipPos(2) + 1.2.*dTooltipPos(4));
    else
        dHeight = fExpAnimation(10, dTooltipPos(2), dTooltipPos(2) - 1.2.*dTooltipPos(4));
    end
    
    for iI = 1:length(dHeight)
        dTooltipPos(2) = dHeight(iI);
        set(obj.STooltip.hAxes, 'Position', dTooltipPos);
        pause(0.01);
    end

    return
end
% -------------------------------------------------------------------------


% ---------------------------------------------------------------------
% Mouse over a line in a view (profile or ROI)
% SView = obj.getView;
% if ~isempty(SView)
%     dPos = get(SView.hAxes, 'CurrentPoint');
%     dX   = get(SView.hLine(1), 'XData');
%     dY   = get(SView.hLine(1), 'YData');
%     iInd = find(abs(dPos(1, 1) - dX) < 5 & abs(dPos(1, 2) - dY) < 5, 1);
%     if ~isempty(iInd)
%         set(obj.hF, 'Pointer', 'fleur');
%     end
% end
% ---------------------------------------------------------------------


% -------------------------------------------------------------------------
% Check if on the boundaries between two views
[obj.SAction.iDividerX, obj.SAction.iDividerY] = fGetDivider(obj);
if ~isempty(obj.SAction.iDividerX)
    set(obj.hF, 'Pointer', 'left')
    set(obj.hF, 'WindowButtonDownFcn', @obj.dividerDown);
    return
elseif ~isempty(obj.SAction.iDividerY)
    set(obj.hF, 'Pointer', 'top')
    set(obj.hF, 'WindowButtonDownFcn', @obj.dividerDown);
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Mouse over a VIEW
[iView, iDimInd] = obj.hViews.isOver(hOver);
obj.SAction.hView = obj.hViews(iView);
obj.SAction.iDimInd = iDimInd;
if ~isempty(obj.SAction.hView)
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % If resclicing mode and in box
    if strcmp(obj.sROIMode, 'reslice') && strcmp(get(SView.hLine(1), 'Visible'), 'on')
        dBox(1, :) = get(SView.hLine(1), 'XData');
        dBox(2, :) = get(SView.hLine(1), 'YData');
        dBox = dBox(:, 2:5);
        dPos = get(SView.hAxes, 'CurrentPoint');
        dPos = dPos(1, 1:2)';
        if fInPolygon(dPos', dBox) == 1
            set(obj.hF, 'Pointer', 'custom', 'PointerShapeCData', dFleur, 'PointerShapeHotSpot', [8 8]);
            return
        end
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % If view is not empty, show data pointer and update sidebar if necessary
    if ~isempty(obj.SAction.hView.hData)
%         fUpdateDataCursor(obj, SView);
        setptr(obj.hF, 'datacursor');
        set(obj.hF, 'WindowButtonDownFcn', @obj.viewDown);
        return
        
    else
        % If view is empty, hide the bottom left text
        set(obj.hF, 'Pointer', 'Arrow');
%         fNoBottomLeftText(obj);
        return
    end
    
else
    % If not over a view, hide the bottom left text
%     obj.hViews.NoBottomLeftText;
end
% -------------------------------------------------------------------------


function fUpdateDataCursor(obj, SView)

iStartDims = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
dPos = get(SView.hAxes, 'CurrentPoint');
dCoord_mm = [dPos(1, 2:-1:1), obj.SData(SView.iData(1)).dDrawCenter(iStartDims(3))];

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Loop over views to show data of all visible views
for iView = 1:numel(obj.SView)
    
    SThisView = obj.SView(iView);
    
    hText = [SThisView.hText];
    if ~isempty(SThisView.iData)
        
        iDims = obj.SData(SThisView.iData(1)).iDims(SThisView.iDimInd, :);
        if all(iDims == iStartDims);
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % This view is not empty and has same orientation as view that has focus
            dImg = obj.getData(SThisView);
            dCoord_px = obj.phys2Pixel(dCoord_mm, SThisView.iData(1), iDims);
            dCoord_px = round(dCoord_px([1, 2]));
            if all(dCoord_px > 0) && all(dCoord_px <= size(dImg(:,:,1)))
                dData = dImg(dCoord_px(1), dCoord_px(2));
                dCoord = [dCoord_mm, dCoord_mm(3)];
                if all(obj.SData(SThisView.iData(1)).dRes == 1) && all(obj.SData(SThisView.iData(1)).dOrigin == 1) && strcmp(obj.SData(SThisView.iData(1)).sUnits, 'px')
                    dCoord = round(dCoord);
                end
                set(hText(2, 1, :), 'Visible', 'on', 'String', ...
                    sprintf('I(%3.1f, %3.1f, %3.1f) = %g', dCoord(iDims == 1), dCoord(iDims == 2), dCoord(iDims == 4), dData));
            else
                set(hText(2, 1, :), 'String', '');
            end
        else
            set(hText(2, 1, :), 'String', '');
        end
    end
end



function [iDX, iDY] = fGetDivider(obj)

iMousePos = get(obj.hF, 'CurrentPoint');
iFigureSize = get(obj.hF, 'Position');

iX = round(fNonLinSpace(obj.iIconSize + 1, iFigureSize(3) + 1, obj.dColWidth(1:obj.iAxes(1))));
iDX = find(abs(iMousePos(1) - iX(2:end-1)) < 10);
iY = round(fNonLinSpace(iFigureSize(4) - obj.iIconSize + 1, 1, obj.dRowHeight(1:obj.iAxes(2))));
iDY = find(abs(iMousePos(2) - iY(2:end-1)) < 10);



function dFleur = fGetFleur
dFleur = ...
   [NaN, NaN, NaN, NaN, NaN, NaN, NaN,   2,   2, NaN, NaN, NaN, NaN, NaN, NaN, NaN; ...
    NaN, NaN, NaN, NaN, NaN, NaN,   2,   1,   1,   2, NaN, NaN, NaN, NaN, NaN, NaN; ... 
    NaN, NaN, NaN, NaN, NaN,   2,   1,   1,   1,   1,   2, NaN, NaN, NaN, NaN, NaN; ... 
    NaN, NaN, NaN, NaN,   2,   1,   1,   1,   1,   1,   1,   2, NaN, NaN, NaN, NaN; ...
    NaN, NaN, NaN,   2, NaN,   2,   2,   1,   1,   2,   2, NaN,   2, NaN, NaN, NaN; ...
    NaN, NaN,   2,   1,   2, NaN,   2,   1,   1,   2, NaN,   2,   1,   2, NaN, NaN; ...
    NaN,   2,   1,   1,   2,   2,   2,   1,   1,   2,   2,   2,   1,   1,   2, NaN; ...
      2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2; ...
      2,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   2; ...
    NaN,   2,   1,   1,   2,   2,   2,   1,   1,   2,   2,   2,   1,   1,   2, NaN; ...
    NaN, NaN,   2,   1,   2, NaN,   2,   1,   1,   2, NaN,   2,   1,   2, NaN, NaN; ...
    NaN, NaN, NaN,   2, NaN,   2,   2,   1,   1,   2,   2, NaN,   2, NaN, NaN, NaN; ...
    NaN, NaN, NaN, NaN,   2,   1,   1,   1,   1,   1,   1,   2, NaN, NaN, NaN, NaN; ...
    NaN, NaN, NaN, NaN, NaN,   2,   1,   1,   1,   1,   2, NaN, NaN, NaN, NaN, NaN; ...
    NaN, NaN, NaN, NaN, NaN, NaN,   2,   1,   1,   2, NaN, NaN, NaN, NaN, NaN, NaN; ...
    NaN, NaN, NaN, NaN, NaN, NaN, NaN,   2,   2, NaN, NaN, NaN, NaN, NaN, NaN, NaN];