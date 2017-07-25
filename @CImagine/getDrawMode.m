function sMode = getDrawMode(obj)

iInd = find([obj.SMenu.GroupIndex] == 1 & [obj.SMenu.Active]);
if isempty(iInd)
    sMode = 'mag';
else
    sMode = obj.SMenu(iInd).Name;
end
