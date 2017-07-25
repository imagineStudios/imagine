function backup(obj)

for iI = 1:length(obj)
    obj(iI).OldZoom = obj(iI).Zoom;
    obj(iI).OldDrawCenter = obj(iI).DrawCenter;
end