function rdivide(obj, dDivisor)

for iI = 1:length(obj.SData)
    obj.SData(iI).dWindowCenter = obj.SData(iI).dWindowCenter + obj.SData(iI).dWindowWidth(dDivisor - 1)./2;
    obj.SData(iI).dWindowWidth = obj.SData(iI).dWindowWidth*dDivisor;
end
obj.draw;
obj.tooltip(sprintf('Center %g / Width %g', obj.SData(obj.iStartSeries).dWindowCenter, obj.SData(obj.iStartSeries).dWindowWidth));