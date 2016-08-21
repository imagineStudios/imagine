function zoom(obj, dFactor)

dZoom = obj.OldZoom*exp(dFactor);
dZoomLog = log2(dZoom);
iExp = round(dZoomLog);
if abs(dZoomLog - iExp) < 0.05
    dZoom = 2.^iExp;
end
obj.Zoom = max(0.1, min(32, dZoom));