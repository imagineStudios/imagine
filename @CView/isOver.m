function [iView, iDimInd] = isOver(obj, hOver)

lOver = false(length(obj(1).hA), length(obj));
if isa(hOver, 'matlab.graphics.axis.Axes')
    for iI = 1:numel(obj)
        lVector = hOver == obj(iI).hA;
        lOver(1:length(lVector), iI) = lVector;
    end
    [iDimInd, iView] = find(lOver);
else
    iDimInd = [];
    iView = [];
end

