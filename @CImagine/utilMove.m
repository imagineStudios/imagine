function utilMove(obj, ~, ~)

dPos = round(get(obj.SAxes.hUtil, 'CurrentPoint'));
dXLim = get(obj.SAxes.hUtil, 'XLim') + 0.5;
dYLim = get(obj.SAxes.hUtil, 'YLim') + 0.5;

if dPos(1, 1) >= dXLim(1) && dPos(1, 1) < dXLim(2) && ...
        dPos(1, 2) >= dYLim(1) && dPos(1, 2) < dYLim(2)
    
    dMask = ones(obj.iMAXVIEWS).*0.5;
    dMask(1:dPos(1, 2), 1:dPos(1, 1)) = 0.8;
    set(obj.SImgs.hUtil, 'AlphaData', dMask);
    
end
% ---------------------------------------------------------------------