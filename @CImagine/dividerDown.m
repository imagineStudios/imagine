function dividerDown(obj, ~, ~)

iFigureSize = get(obj.hF, 'Position');
obj.SAction.iPos = get(obj.hF, 'CurrentPoint');
obj.SAction.dColWidth = obj.dColWidth;
obj.SAction.dRowHeight = obj.dRowHeight;

if ~isempty(obj.SAction.iDividerX)
    iX = round(fNonLinSpace(obj.iIconSize + 1, iFigureSize(3) + 1, obj.dColWidth(1:obj.iAxes(1))));
    obj.SAction.dWidth = diff(iX);
elseif ~isempty(obj.SAction.iDividerY)
    iY = round(fNonLinSpace(iFigureSize(4) - obj.iIconSize + 1, 1, obj.dRowHeight(1:obj.iAxes(2))));
    obj.SAction.dHeight = -diff(iY);
end

set(obj.hF, 'WindowButtonMotionFcn', @obj.dividerDrag, ...
            'WindowBUttonUpFcn',     @obj.dividerUp);