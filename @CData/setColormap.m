function setColormap(obj, xMap)

if isnumeric(xMap)
    obj.Colormap = obj.Parent.SColormaps(xMap);
elseif ischar(xMap)
  csColormaps = {obj.Parent.SColormaps.sName};
  iInd = find(strcmp(csColormaps, xMap));
  if ~isempty(iInd)
    obj.Colormap = obj.Parent.SColormaps(iInd);
  else
    obj.Colormap = obj.Parent.SColormaps(1);
  end
else
  obj.Colormap = xMap;
end

