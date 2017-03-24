function [sMap, iInd] = getColormap(obj)
sMap = obj.Colormap.sMap;
iInd = find(strcmp(obj.Colormaps, obj.Colormap.sMap));