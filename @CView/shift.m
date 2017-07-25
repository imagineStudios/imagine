function shift(obj, dDelta)

for iI = 1:numel(obj)
    if isempty(obj(iI).hData), continue, end
    obj(iI).DrawCenter = obj(iI).DrawCenter + dDelta;
end