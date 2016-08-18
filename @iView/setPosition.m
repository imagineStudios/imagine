function setPosition(obj, iX, iY, iWidth, iHeight)

iAxesPerView = 1 + double(strcmp(obj(1).Mode, '3D'))*2;

for iI = 1:length(obj)
    o = obj(iI);

    iStartPos = (o.Ind - 1)*iAxesPerView + 1;

%     obj.dPosition = dPosition;
    for iJ = 1:length(o.hA)
        iPos = iStartPos + iJ - 1;
        set(o.hA(iJ), 'Position', [iX(iPos), iY(iPos), iWidth(iPos), iHeight(iPos)]);
    end

% if ~isempty(obj.hT)
%     set(obj.hText(1, 1, 1), 'Position', [10, iHeight - 10 - obj.lRuler.*20]);
%     set(obj.hText(1, 1, 2), 'Position', [9, iHeight - 9 - obj.lRuler.*20]);
%     set(obj.hText(1, 2, 1), 'Position', [iWidth - 10 - obj.lRuler.*20, iHeight - 10 - obj.lRuler.*20]);
%     set(obj.hText(1, 2, 2), 'Position', [iWidth - 11 - obj.lRuler.*20, iHeight - 9 - obj.lRuler.*20]);
%     set(obj.hText(2, 2, 1), 'Position', [iWidth - 10, 10]);
%     set(obj.hText(2, 2, 2), 'Position', [iWidth - 11, 11] + 2);
% end

end
obj.position;