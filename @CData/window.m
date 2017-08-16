function window(obj, dFactor)

for iI = 1:length(obj)
  hData = obj.(iI);
  dCenter = hData.OldCenter.*exp( dFactor(1));
  dWidth  = hData.OldWidth .*exp(-dFactor(2));
  hData.Window = dCenter + dWidth./2.*[-1, 1];
end
