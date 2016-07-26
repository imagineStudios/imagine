function dVal = getSlider(obj, sName)

lInd = strcmp(sName, {obj.SSliders.Name});
dVal = get(obj.SSliders(lInd).hScatter, 'XData');