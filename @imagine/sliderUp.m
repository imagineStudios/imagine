function sliderUp(obj, ~, ~)

set(obj.hF, 'WindowButtonMotionFcn', @obj.mouseMove, ...
            'WindowButtonUpFcn', '');