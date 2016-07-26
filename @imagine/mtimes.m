function mtimes(obj, dFactor)

for iI = 1:length(obj.SData)
    obj.SData(iI).dZoom = dFactor;
end
obj.tooltip(sprintf('%d %%', round(dFactor*100)));
obj.position;