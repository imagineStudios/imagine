function sTool = getTool(obj)

iInd = [obj.SMenu.GroupIndex] == 255 & ...
       [obj.SMenu.Active];
   
sTool = obj.SMenu(iInd).Name;