function sliderDrag(obj, hObject, eventdata)

obj.SAction.lMoved = true;

iInd = obj.SAction.iSlider;

dVal = get(obj.SSliders(iInd).hAxes, 'CurrentPoint');
dLim = get(obj.SSliders(iInd).hAxes, 'XLim');
dVal = min(dLim(2), max(dLim(1), dVal(1, 1)));

if obj.SSliders(iInd).Snap
    dTicks = obj.SSliders(iInd).Tick;
    if strcmp(obj.SSliders(iInd).Scale, 'log')
        dTicks = log2(dTicks);
        dVal = log2(dVal);
    end
    
    if obj.SSliders(iInd).Snap == 1
        dDiff = dTicks(end) - dTicks(1);
        iTickInd = find(abs(dVal - dTicks) < 0.05*dDiff, 1, 'first');
    else
        [~, iTickInd] = min(abs(dVal - dTicks));
    end
    
    if iTickInd
        dVal = dTicks(iTickInd);
    end
    if strcmp(obj.SSliders(iInd).Scale, 'log')
        dVal = 2.^dVal;
    end
end
set(obj.SSliders(iInd).hScatter, 'XData', dVal);

obj.tooltip(sprintf('%s: %4.2f', obj.SSliders(iInd).Name, dVal));

if strcmp(obj.SSliders(iInd).Name, 'Gamma')
    obj.setColormap(obj.sColormap);
end
obj.draw;
obj.grid;