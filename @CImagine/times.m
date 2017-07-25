function times(obj, dFactor)

for iI = 1:length(obj.SData)
    obj.SData(iI).dWindowCenter = obj.SData(iI).dWindowCenter + obj.SData(iI).dWindowWidth.*(1/dFactor - 1)./2;
    obj.SData(iI).dWindowWidth = obj.SData(iI).dWindowWidth./dFactor;
end
obj.draw;
obj.tooltip(sprintf('Center %g / Width %g', obj.SData(obj.iStartSeries).dWindowCenter, obj.SData(obj.iStartSeries).dWindowWidth));