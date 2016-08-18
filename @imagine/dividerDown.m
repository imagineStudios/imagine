function dividerDown(obj, ~, ~)

obj.SAction.iPos = get(obj.hF, 'CurrentPoint');
obj.SAction.dColWidth = obj.dColWidth;
obj.SAction.dRowHeight = obj.dRowHeight;

if obj.SAction.iDivider(1)
    dPixels(1,:) = obj.hViews(obj.SAction.iDivider(1), 1).dPosition;
    dPixels(2,:) = obj.hViews(obj.SAction.iDivider(1) + 1, 1).dPosition;
    obj.SAction.dPixels = dPixels(:, 3);
    
elseif obj.SAction.iDivider(2)
    dPixels(1,:) = obj.hViews(1, obj.SAction.iDivider(2)).dPosition;
    dPixels(2,:) = obj.hViews(1, obj.SAction.iDivider(2) + 1).dPosition;
    obj.SAction.dPixels = dPixels(:, 4);
end

set(obj.hF, 'WindowButtonMotionFcn', @obj.dividerDrag, ...
            'WindowBUttonUpFcn',     @obj.dividerUp);