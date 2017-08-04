function dImg = fDecimate(dImg, iFactor)

dImg = (dImg(1:2:end, 1:2:end) + ...
        dImg(1:2:end, 2:2:end) + ...
        dImg(2:2:end, 1:2:end) + ...
        dImg(2:2:end, 2:2:end))./4;
      
iFactor = iFactor/2;
if iFactor > 1
  dImg = iGlobals.fDecimate(dImg, iFactor);
end