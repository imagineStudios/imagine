function setPosition(obj, iX, iY, iWidth, iHeight)

l3D = obj(1).hParent.get3DMode();
iAxesPerView = 1 + double(l3D)*2;

iRuler = 20.*double(obj(1).hParent.lRuler);

for iI = 1:length(obj)
  o = obj(iI);
  
  iStartPos = (o.Ind - 1)*iAxesPerView + 1;
  
  %     obj.dPosition = dPosition;
  for iJ = 1:length(o.hA)
    iPos = iStartPos + iJ - 1;
    set(o.hA(iJ), 'Position', ...
      [iX(iPos) + iRuler, iY(iPos), iWidth(iPos) - iRuler, iHeight(iPos) - iRuler]);
    
    if ~isempty(o.hT)
      set(o.hT(1, 1, 1, iJ), 'Position', [30, iHeight(iPos) - 10 - iRuler]);
      set(o.hT(1, 1, 2, iJ), 'Position', [29, iHeight(iPos) -  9 - iRuler]);
%       set(o.hT(1, 2, 1, iJ), 'Position', [iWidth(iPos) - 10 - iRuler, iHeight(iPos) - 10 - iRuler]);
%       set(o.hT(1, 2, 2, iJ), 'Position', [iWidth(iPos) - 11 - iRuler, iHeight(iPos) -  9 - iRuler]);
%       set(o.hT(2, 2, 1, iJ), 'Position', [iWidth(iPos) - 10, 10]);
%       set(o.hT(2, 2, 2, iJ), 'Position', [iWidth(iPos) - 11, 11]);
    end
  end
  
  
  
end
obj.position;
obj.grid;