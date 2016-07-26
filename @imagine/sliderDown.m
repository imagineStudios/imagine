function sliderDown(obj, ~, ~)

set(obj.hF, 'WindowButtonMotionFcn', @obj.sliderDrag, 'WindowButtonUpFcn', @obj.sliderUp);