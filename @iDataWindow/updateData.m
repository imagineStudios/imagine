function updateData(obj)

if isempty(obj.hActivePanel), return, end

obj.hActivePanel.hData.Alpha = obj.hSlider.Value/100;
obj.hActivePanel.hData.setColormap(obj.hC(3).Ind);
notify(obj, 'update');