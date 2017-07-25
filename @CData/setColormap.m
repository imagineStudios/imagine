function setColormap(obj, SMap)

if isnumeric(SMap)
    SMap = obj.Parent.SColormaps(SMap);
end

obj.Colormap = SMap;
% obj.Colormap.dMap = obj.Colormap.hFcn(1024, 1);