function contextMenu(obj, iInd, ~)

if isnumeric(iInd) && iInd > 0
    
    iInd = find([obj.SMenu.SubGroupInd] == iInd);
    dYLimTarget(1) = get(obj.SImgs.hIcons(iInd(1)), 'YData');
    dYLimTarget(2) = get(obj.SImgs.hIcons(iInd(end)), 'YData') + obj.iIconSize;
    
    dYLimStart = get(obj.SAxes.hContext, 'YLim');
    if diff(dYLimStart) < 2
        dYLimStart = [dYLimTarget(1), dYLimTarget(1) + 1];
        dPos = get(obj.hF, 'CurrentPoint');
        dYStart = dPos(2);
    else
        dPos = get(obj.SAxes.hContext, 'Position');
        dYStart = dPos(2) + dPos(4);
    end
    
    dStartHeight = diff(dYLimStart);
    dTargetHeight = diff(dYLimTarget);
    
    if dTargetHeight > dYStart
        dFigureSize = get(obj.hF, 'Position');
        dYEnd = min(dTargetHeight, dFigureSize(4));
    else
        dYEnd = dYStart;
    end
    
    set(obj.SAxes.hContext, 'XLim', [0 obj.iIconSize] + 0.5);
    
    dPos = [dPos(1), dYStart, obj.iIconSize, 1];
    for dVal = fExpAnimation(20, 1, 0);
        dYLim = (1 - dVal)*dYLimTarget + dVal*dYLimStart;
        iHeight = (1 - dVal)*dTargetHeight + dVal*dStartHeight;
        iY = (1 - dVal)*dYEnd + dVal*dYStart;
        dPos(2) = iY - iHeight;
        dPos(4) = iHeight;
        set(obj.SAxes.hContext, 'Position', dPos, 'YLim', dYLim + 0.5);
        drawnow update
        pause(0.01);
    end
else
    set(obj.SAxes.hContext, 'Position', [1 1 1 1], 'YLim', [0.5 1.5]);
end