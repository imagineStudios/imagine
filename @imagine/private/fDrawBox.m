[dX, dY] = fDrawBox(dA, dB)

dX = get(obj.SAction.SView.hLine(1), 'XData');
dY = get(obj.SAction.SView.hLine(1), 'YData');

dB = [dX(2) - dX(1); dY(2) - dY(1)];
dA = 0.5.*[0 -1; 1 0]*dB;

dX = [dX(1), dX(1) + dA(1), dX(1) + dA(1) + dB(1), dX(2) - dA(1), dX(2) - dA(1) - dB(1), dX];
dY = [dY(1), dY(1) + dA(2), dY(1) + dA(2) + dB(2), dY(2) - dA(2), dY(2) - dA(2) - dB(2), dY];