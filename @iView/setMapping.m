function setMapping(obj, ~, ~)
if length(obj.hParent.ViewMapping) >= obj.Ind
    obj.hData = obj.hParent.hData(obj.hParent.ViewMapping{obj.Ind});
    if isempty(obj.DrawCenter) && ~isempty(obj.hData)
        obj.DrawCenter = obj.hData(1).getCenter;
    end
else
    obj.hData = [];
end
obj.draw;
obj.position;
end