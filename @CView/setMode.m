function setMode(obj, l3D)
for iI = 1:numel(obj)
    if l3D
        obj(iI).sMode = '3D';
    else
        obj(iI).sMode = '2D';
    end
end