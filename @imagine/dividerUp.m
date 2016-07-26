function dividerUp(obj, ~, ~)

set(obj.hF, 'WindowButtonMotionFcn', @obj.mouseMove, ...
            'WindowButtonUpFcn', '');