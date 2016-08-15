function dZLim = get3Lim(obj)

if any(strcmp(obj.Parent.getDrawMode, {'min', 'max'}));
    dMipDepth = obj.Parent.getSlider('Projection Depth');
    dZLim = obj.DrawCenter(4) + 0.5.*[-dMipDepth dMipDepth];
else
    dZLim = [obj.DrawCenter(4), obj.DrawCenter(4)];
end

