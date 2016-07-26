function sMode = getMode(obj)

iInd = [obj.SMenu.GroupIndex] == 256 & [obj.SMenu.Active];
sMode = obj.SMenu(iInd).Name;
