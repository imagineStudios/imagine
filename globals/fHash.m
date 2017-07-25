function iHashVal = fHash(sString)
dString = double(sString);
dHashVal = 5381;
for iI = 1:length(dString)
    dHashVal = mod(dHashVal * 33 + dString(iI), 2.^32 - 1);
end
iHashVal = uint32(dHashVal);