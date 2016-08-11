function setPosition(obj, ~, ~)

set(obj.hA, 'Position', obj.Position);

if ~isempty(obj.hT)
    set(obj.hText(1, 1, 1), 'Position', [10, iHeight - 10 - obj.lRuler.*20]);
    set(obj.hText(1, 1, 2), 'Position', [9, iHeight - 9 - obj.lRuler.*20]);
    set(obj.hText(1, 2, 1), 'Position', [iWidth - 10 - obj.lRuler.*20, iHeight - 10 - obj.lRuler.*20]);
    set(obj.hText(1, 2, 2), 'Position', [iWidth - 11 - obj.lRuler.*20, iHeight - 9 - obj.lRuler.*20]);
    set(obj.hText(2, 2, 1), 'Position', [iWidth - 10, 10]);
    set(obj.hText(2, 2, 2), 'Position', [iWidth - 11, 11] + 2);
end

obj.position;
