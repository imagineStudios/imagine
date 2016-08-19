function dividerDrag(obj, ~, ~)

obj.SAction.lMoved = true;

iPos = get(obj.hF, 'CurrentPoint');
dD = iPos - obj.SAction.iPos;

if ~isempty(obj.SAction.iDividerX)
    iPos = obj.SAction.iDividerX;
    dWidthSum = sum(obj.SAction.dWidth(iPos:iPos + 1));
    dNewWidth = obj.SAction.dWidth;
    dNewWidth(iPos) = min(max(10, obj.SAction.dWidth(iPos) + dD(1)), dWidthSum - 10);
    dNewWidth(iPos + 1) = dWidthSum - dNewWidth(iPos);
    dNewPropWidth = dNewWidth./sum(dNewWidth).*sum(obj.dColWidth(1:obj.iAxes(1)));
    obj.dColWidth(1:obj.iAxes(1)) = dNewPropWidth;
else
    iPos = obj.SAction.iDividerY;
    dHeightSum = sum(obj.SAction.dHeight(iPos:iPos + 1));
    dNewHeight = obj.SAction.dHeight;
    dNewHeight(iPos) = min(max(10, obj.SAction.dHeight(iPos) - dD(2)), dHeightSum - 10);
    dNewHeight(iPos + 1) = dHeightSum - dNewHeight(iPos);
    dNewPropHeight = dNewHeight./sum(dNewHeight).*sum(obj.dRowHeight(1:obj.iAxes(2)));
    obj.dRowHeight(1:obj.iAxes(2)) = dNewPropHeight;
end
obj.resize(0);