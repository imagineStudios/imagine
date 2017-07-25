function window(obj, dFactor)
for iI = 1:length(obj)
    dCenter = obj(iI).OldCenter.*exp(dFactor(1));
    dWidth  = obj(iI).OldWidth.*exp(-dFactor(2));
    obj(iI).Window = dCenter + 0.5.*[-dWidth, dWidth];
end
