function setMode(obj, l3D)
for iI = 1:numel(obj)
    if l3D
        obj(iI).Mode = '3D';
    else
        obj(iI).Mode = '2D';
    end
    obj(iI).setAxes;
end