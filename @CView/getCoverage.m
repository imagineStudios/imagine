function dCoverage = getCoverage(obj)

if isempty(obj.hData)
    dCoverage = [];
    return
end

for iI = 1:length(obj.hData)
    if iI == 1
        dCoverage = [obj.hData(iI).dOrigin; obj.hData(iI).getCoverage];
    else
        dCoverage(1,:) = min([dCoverage(1,:); obj.hData(iI).dOrigin]);
        dCoverage(2,:) = max([dCoverage(2,:); obj.hData(iI).getCoverage]);
    end
end