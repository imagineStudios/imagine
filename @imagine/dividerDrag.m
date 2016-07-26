function dividerDrag(obj, ~, ~)

obj.SAction.lMoved = true;

iPos = get(obj.hF, 'CurrentPoint');
dD = iPos - obj.SAction.iPos;

if obj.SAction.iDivider(1)
    dNewPixels(1) = obj.SAction.dPixels(1) + dD(1);
    dNewPixels(1) = min(max(10, dNewPixels(1)), sum(obj.SAction.dPixels) - 10);
    dNewPixels(2) = sum(obj.SAction.dPixels) - dNewPixels(1);
    
    dWidth = obj.dColWidth(obj.SAction.iDivider(1):obj.SAction.iDivider(1) + 1);
    dWidth = dNewPixels./sum(obj.SAction.dPixels).*sum(dWidth);
    obj.dColWidth(obj.SAction.iDivider(1):obj.SAction.iDivider(1) + 1) = dWidth;
else
    dNewPixels(1) = obj.SAction.dPixels(1) - dD(2);
    dNewPixels(1) = min(max(10, dNewPixels(1)), sum(obj.SAction.dPixels) - 10);
    dNewPixels(2) = sum(obj.SAction.dPixels) - dNewPixels(1);
    
    dHeight = obj.dRowHeight(obj.SAction.iDivider(2):obj.SAction.iDivider(2) + 1);
    dHeight = dNewPixels./sum(obj.SAction.dPixels).*sum(dHeight);
    obj.dRowHeight(obj.SAction.iDivider(2):obj.SAction.iDivider(2) + 1) = dHeight;
end
obj.resize(0);