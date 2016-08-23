function setData(obj, cData)

% -------------------------------------------------------------------------
% Determine data source for current view
for iI = 1:numel(obj)
    
    o = obj(iI);
        
    if length(cData) >= o.Ind
        o.hData = cData{o.Ind};
        if isempty(o.DrawCenter) && ~isempty(o.hData)
            o.DrawCenter = o.hData(1).getCenter;
        end
    else
        o.hData = [];
    end
end

if strcmp(get(obj(1).hParent.hF, 'Visible'), 'on')
    obj.draw(obj(1).hParent.getHDMode);
    obj.position;
end