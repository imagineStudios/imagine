function setColormap(obj, sColormap)

iCOLORMAPLENGTH         = 2.^12;

dGamma = obj.getSlider('Gamma');

hFunction = str2func(['cmap_', lower(sColormap)]);

obj.dColormap = hFunction(iCOLORMAPLENGTH, dGamma);
obj.sColormap = sColormap;

if strcmp(get(obj.hF, 'Visible'), 'on'), obj.draw; end