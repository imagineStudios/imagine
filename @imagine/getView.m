function hView = getView(obj)

dPos = reshape([obj.hViews.Position]', 4, []);
dXStart = dPos(1, :);
dYStart = dPos(2, :);
dXEnd = dXStart + dPos(3, :);
dYEnd = dYStart + dPos(4, :);

dMousePos = get(obj.hF, 'CurrentPoint');

lMask = dMousePos(1) >= dXStart & dMousePos(1) <= dXEnd ...
      & dMousePos(2) >= dYStart & dMousePos(2) <= dYEnd;

hView = obj.hViews(lMask);
