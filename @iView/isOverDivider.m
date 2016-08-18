function iDivider = isOverDivider(obj, dCoord_px)

iDivider = [0, 0];

dPos = obj.Position;

dDiff = abs(dCoord_px(1, 1) - (dPos(1) + [0, dPos(3)]));
iDivider(1) = find([0, dDiff] < 10, 1, 'last') - 1;

dDiff = abs(dCoord_px(1, 2) - (dPos(2) + [0, dPos(4)]));
iDivider(2) = find([0, dDiff] < 10, 1, 'last') - 1;