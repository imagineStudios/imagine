function updateData(obj)

hData = obj(1).hParent.hData;

for iI = 1:length(obj)
    
    o = obj(iI);
    lShow = false(size(hData));
    
    for iJ = 1:length(lShow)
        if any(hData(iJ).Views == o.Ind)
            lShow(iJ) = true;
        end
    end
    o.hData = hData(lShow);
    
    if isempty(o.DrawCenter)
        if o.Ind == 1
            if ~isempty(o.hData)
                o.DrawCenter = o.hData(1).getCenter();
            end
        else
            o.DrawCenter = o.hParent.hViews(o.Ind - 1).DrawCenter;
        end
    end
    
    iNQuiver = sum(strcmp([o.hData.Type], 'vector'));
    iNImg = length(o.hData) - iNQuiver;
    
end