function position(obj, ~, ~)
% iView.POSITION Responsisble for positioning the contents of the views correctly.

l3D = obj(1).hParent.get3DMode();

for iI = 1:length(obj)
  
  hView = obj(iI);
  
  for iAxesInd = 1:length(hView.hA)
    
    dAxesPos = get(hView.hA(iAxesInd), 'Position');
    
    if ~isempty(hView.hData)
      
      % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
      % Get the image data, do windowing and apply colormap
      if l3D
        dA = hView.dA(:,:,iAxesInd);
      else
        switch(hView.hData(1).Orientation)
          case 'cor', dA = hView.dA(:,:,1);
          case 'sag', dA = hView.dA(:,:,2);
          case 'tra', dA = hView.dA(:,:,3);
          case 'nat', dA = hView.dA(:,:,3);
        end
      end
      
      dMinRes = min(hView.hParent.dMinRes(1:3));
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % Panel not empty
      csDirs = {'normal', 'reverse'};
      iDimPermutation = abs(dA'*[1 2 3]');
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % Determine the limits of x- and y-axes
      dDelta_phys = dAxesPos([4, 3])./hView.Zoom * dMinRes;
      
      dXLim_mm = hView.DrawCenter(iDimPermutation(2)) + 0.5 * [-dDelta_phys(2) dDelta_phys(2)];
      dYLim_mm = hView.DrawCenter(iDimPermutation(1)) + 0.5 * [-dDelta_phys(1) dDelta_phys(1)];
      
      set(hView.hA(iAxesInd), 'XLim', dXLim_mm, 'YLim', dYLim_mm);%, ...
        %'XDir', csDirs{ hView.hData(1).Invert(iDimPermutation(2)) + 1}, ...
        %'YDir', csDirs{~hView.hData(1).Invert(iDimPermutation(1)) + 1});
      
    else
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % Panel is empty
      dSize = dAxesPos([4 3]);
      dLim = 16./max(dSize).*dSize;
      set(hView.hA(iAxesInd), 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
        'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5, ...
        'XDir', 'normal', 'YDir', 'reverse');
      
    end
  end
end

