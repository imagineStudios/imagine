function dividerDown(obj, ~, ~)

obj.SAction.iPos = get(obj.hF, 'CurrentPoint');
obj.SAction.dColWidth = obj.dColWidth;
obj.SAction.dRowHeight = obj.dRowHeight;

if obj.SAction.iDivider(1)
    dPixels(1,:) = get(obj.SView(obj.SAction.iDivider(1), 1).hAxes, 'Position');
    dPixels(2,:) = get(obj.SView(obj.SAction.iDivider(1) + 1, 1).hAxes, 'Position');
    obj.SAction.dPixels = dPixels(:, 3);
    
elseif obj.SAction.iDivider(2)
    dPixels(1,:) = get(obj.SView(1, obj.SAction.iDivider(2)).hAxes, 'Position');
    dPixels(2,:) = get(obj.SView(1, obj.SAction.iDivider(2) + 1).hAxes, 'Position');
    obj.SAction.dPixels = dPixels(:, 4);
end

set(obj.hF, 'WindowButtonMotionFcn', @obj.dividerDrag, ...
            'WindowBUttonUpFcn',     @obj.dividerUp);