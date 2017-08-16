function draw(obj, lHD)

persistent dBGImg
% dBGImg = [];
if isempty(dBGImg)
  dBGImg = fBGImg(obj(1).hParent.SColors.bg_normal);
end

% -------------------------------------------------------------------------
% Determine some drawing parameters
% dGamma         = get(obj.SSliders(1).hScatter, 'XData');
% dMaskAlpha     = obj.getSlider('Mask Alpha');
% dQuiverWidth   = obj.getSlider('Quiver Width');
l3D = obj(1).hParent.get3DMode();
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Loop over all views
for iI = 1:numel(obj)
  
  hView = obj(iI);
  
  if isempty(hView.hData)
    
    set(hView.hI, ...
      'CData'     , dBGImg, ...
      'AlphaData' , 1, ...
      'XData'     , [1 size(dBGImg, 2)], ...
      'YData'     , [1 size(dBGImg, 1)]);
    
    set(hView.hT(:), 'Visible', 'off');
  else
    
    for iAxesInd = 1:length(hView.hA)
      for iJ = 1:length(obj(iI).hData)
        
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
        
        [dImg, dXData, dYData, dAlpha] = ...
          obj(iI).hData(iJ).getData(hView.DrawCenter, dA, hView.hA(iAxesInd));
        
        if ~strcmp(obj(iI).hData(iJ).Type, 'vector')
          % It's image data
          set(hView.hI(iAxesInd, iJ), ...
            'CData'     , dImg, ...
            'AlphaData' , dAlpha, ...
            'XData'     , dXData, ...
            'YData'     , dYData);
          
        else
          % Its a quiver plot
          set(SView.hQuiver, ...
            'XData'     , dXData, ...
            'YData'     , dYData, ...
            'Visible'   , 'on', ...
            'LineWidth' , dQuiverWidth);
          
          set(SView.hQuiver.Edge, ...
            'ColorBinding'  , 'interpolated', ...
            'ColorData'     , uint8(dImg))
        end
      end
      set(obj(iI).hT(1, 1, :, :), 'String', sprintf('%s', obj(iI).hData.Name), 'Visible', 'on');
      
    end
  end
end



% if lHD && ~strcmp(obj.SData(iSeries).sMode, 'vector') && ~strcmp(obj.SData(iSeries).sMode, 'categorical')

% -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% Fancy mode: Interpolate the images to full resolution. Is
% executed when arbitrary input is supplied or the timer fires.

% -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
% Pad the image for better boundary extrapolation
%     dImg = [dImg(:,1), dImg, dImg(:, end)];
%     dImg = [dImg(1,:); dImg; dImg(end, :)];
%     dX = (-1:size(dImg, 2) - 2).*dAspect(2) + dOrigin(2);
%     dY = (-1:size(dImg, 1) - 2).*dAspect(1) + dOrigin(1);




function dImg = fBGImg(dColor)
dLogo = [0 0 0 1 1 0 0 0; ...
  0 0 0 1 1 0 0 0; ...
  0 0 0 0 0 0 0 0; ...
  0 0 1 1 1 0 0 0; ...
  0 0 0 1 1 0 0 0; ...
  0 0 0 1 1 0 0 0; ...
  0 0 1 1 1 1 0 0; ...
  0 0 0 0 0 0 0 0;];
dPattern = 0.8 + 0.1*rand(16) + 0.2*padarray(dLogo, [4 4], 0, 'both');
dPattern = dPattern.*repmat(linspace(1, 0.8, 16)', [1, 16]);
dPattern = repmat(dPattern, [1 1 3]);

dImg = repmat(permute(dColor, [1 3 2]), [16 16 1]).*dPattern;