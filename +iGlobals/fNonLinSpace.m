function dPos = fNonLinSpace(dStart, dEnd, dRelDistance)

dInt = cumsum(dRelDistance./sum(dRelDistance));
dPos = [dStart, (dEnd - dStart).*dInt + dStart];