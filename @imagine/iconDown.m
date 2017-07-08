function iconDown(obj, hObject, ~)

% -------------------------------------------------------------------------
% Create the checkerboard image for the layout menu
persistent dGridImg

% dGridImg = [];
if isempty(dGridImg)
  dGridImg = 1 - 0.7.*rand(obj.iMAXVIEWS);
  dGridImg = fBlend(3*obj.dBGCOLOR, dGridImg, 'Multiply', 0.5);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Get the source
if ischar(hObject)
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Was called from another subroutine (supplying label string)
  iInd = find(strcmp(hObject, {obj.SMenu.Name}));
else
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Called from an icon (image)
  iInd = find(obj.SImgs.hIcons == hittest);
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Exit if false alert or corresponding button is not enabled
if isempty(iInd), return, end
if ~obj.SMenu(iInd).Enabled, return, end;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% If icon spawns a context menu, do so
if obj.SMenu(iInd).SubGroup
  obj.contextMenu(obj.SMenu(iInd).SubGroup);
else
  obj.contextMenu(0);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Distinguish the idfferent button types (normal, toggle, radio)
sActivate = [];
switch obj.SMenu(iInd).GroupIndex
  
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % NORMAL pushbuttons
  case -1
    
    switch(obj.SMenu(iInd).Name)
      
      
      case 'layers1'
        
        switch obj.sROIMode
          
          case 'line'
            
            dX = get(obj.SAction.SView.hLine(1), 'XData');
            dY = get(obj.SAction.SView.hLine(1), 'YData');
            
            dXTick = [dX(2) - dX(1); dY(2) - dY(1)];
            dA = 0.5.*[0 -1; 1 0]*dXTick;
            
            dX = [dX(1), dX(1) + dA(1), dX(1) + dA(1) + dXTick(1), dX(2) - dA(1), dX(2) - dA(1) - dXTick(1), dX];
            dY = [dY(1), dY(1) + dA(2), dY(1) + dA(2) + dXTick(2), dY(2) - dA(2), dY(2) - dA(2) - dXTick(2), dY];
            
            %                         iDim = obj.SData(obj.SAction.SView.iData(1)).iDims(obj.SAction.SView.iDimInd, :);
            for iView = 1:numel(obj.SView)
              SView = obj.SView(iView);
              %                             if all(iDim == obj.SData(SView.iData(1)).iDims(SView.iDimInd, :));
              if strcmp(get(SView.hLine(1), 'Visible'), 'on')
                set(SView.hLine, 'XData', dX, 'YData', dY, 'Visible', 'on');
                %                             else
                %                                 set(SView.hLine, 'Visible', 'off');
              end
            end
            
            set(obj.SAction.SView.hLine, 'XData', dX, 'YData', dY);
            obj.sROIMode = 'reslice';
            
          case 'reslice'
            
            obj.tooltip('Reslicing...'); drawnow
            
            iData = obj.SAction.SView.iData(1);
            iDim = obj.SData(iData).iDims(obj.SAction.SView.iDimInd, :);
            
            iSeriesToReslice = [];
            for iView = 1:numel(obj.SView)
              if strcmp(get(obj.SView(iView).hLine(1), 'Visible'), 'on')
                iSeriesToReslice = [iSeriesToReslice, obj.SView(iView).iData];
              end
            end
            
            dRes = reshape([obj.SData(obj.SAction.SView.iData).dRes], 5, []);
            dRes = dRes(iDim([1 2]), :);
            dRes = min(dRes(:)); % Minimum in-plane spacing of all series
            
            dX = get(obj.SAction.SView.hLine(1), 'XData');
            dY = get(obj.SAction.SView.hLine(1), 'YData');
            
            dCorner = [dX(5); dY(5)];
            dXTick = [dX(end) - dX(end - 1); dY(end) - dY(end - 1)]; % The new x direction
            
            % Build a rotation matrix
            dXTickNorm = dXTick./norm(dXTick);
            dYTickNorm = [0 -1; 1 0]*dXTickNorm;
            dR = [dXTickNorm, dYTickNorm];
            
            % Define the new coordinate system
            iN = ceil(norm(dXTick)./dRes);
            dXI = (0:iN - 1).*dRes;
            dYI = dXI';
            [dXX, dYY] = meshgrid(dXI, dYI);
            dI = [dXX(:)'; dYY(:)'];
            dI = dR*dI + repmat(dCorner, [1, iN*iN]);
            
            for iData = iSeriesToReslice % obj.SAction.SView.iData;
              
              dImg = obj.SData(iData).dImg;
              iSize = fSize(dImg, 1:5);
              
              dOldRes = obj.SData(iData).dRes   (iDim(1:2));
              dOrigin = obj.SData(iData).dOrigin(iDim(1:2));
              
              dX = (0:iSize(2) - 1).*dOldRes(2) + dOrigin(2);
              dY = (0:iSize(1) - 1).*dOldRes(1) + dOrigin(1);
              
              dImg = reshape(dImg, size(dImg, 1), size(dImg, 2), []); % Colapsel additional dimensions
              dNewImg = zeros(iN, iN, size(dImg, 3));
              
              for iZ = 1:size(dImg, 3)
                dNewImg(:,:,iZ) = reshape(interp2(dX, dY, dImg(:,:,iZ), dI(1, :), dI(2,:), 'bilinear', 0), iN, iN, []);
              end
              
              dNewImg = reshape(dNewImg, iN, iN, iSize(3), iSize(4), iSize(5));
              dNewImg = permute(dNewImg, [4 2 3 1 5]);
              obj.SData(iData).dImg = dNewImg;
              
              obj.SData(iData).dRes(1:2) = dRes;
              obj.SData(iData).dRes = obj.SData(iData).dRes([4 2 3 1 5]);
              
              obj.SData(iData).dOrigin(1:2) = 0;
              obj.SData(iData).dOrigin     = obj.SData(iData).dOrigin    ([4 2 3 1 5]);
              
              obj.SData(iData).dDrawCenter(1:2) = iN./2.*dRes;
              obj.SData(iData).dDrawCenter = obj.SData(iData).dDrawCenter([4 2 3 1 5]);
              obj.SData(iData).lInvert     = obj.SData(iData).lInvert    ([4 2 3 1]);
              
            end
            obj.position;
            obj.draw;
            obj.grid;
            
          otherwise
            
        end
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % LOAD new FILES using file dialog
      case 'folder_open'
        obj.loadFiles;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % IMPORT workspace (base) VARIABLE(S)
      case 'doc_import'
        csVars = fWSImport();
        if isempty(csVars), return, end   % Dialog aborted
        
        for iI = 1:length(csVars)
          dVar = evalin('base', csVars{iI});
          %                     sMode = fGetDataMode(dVar, csVars{iI});
          %                     obj.plus(dVar, 'n', csVars{iI}, 'mode', sMode);
          obj.plus(dVar, 'name', csVars{iI});
        end
        obj.setViews(obj.iAxes(1), obj.iAxes(2));
        obj.hViews.position;
        obj.draw
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % SAVE panel data to file(s)
      case 'save'
        if strcmp(get(hF, 'SelectionType'), 'normal')
          [sFilename, sPath] = uiputfile( ...
            {'*.jpg', 'JPEG-Image (*.jpg)'; ...
            '*.tif', 'TIFF-Image (*.tif)'; ...
            '*.gif', 'Gif-Image (*.gif)'; ...
            '*.bmp', 'Bitmaps (*.bmp)'; ...
            '*.png', 'Portable Network Graphics (*.png)'}, ...
            'Save selected series to files', ...
            [obj.sPath, filesep, '%SeriesName%_%ImageNumber%']);
          if isnumeric(sPath), return, end;   % Dialog aborted
          
          obj.sPath = sPath;
          fSaveToFiles(sFilename, sPath);
        else
          [sFilename, sPath] = uiputfile( ...
            {'*.jpg', 'JPEG-Image (*.jpg)'; ...
            '*.tif', 'TIFF-Image (*.tif)'; ...
            '*.gif', 'Gif-Image (*.gif)'; ...
            '*.bmp', 'Bitmaps (*.bmp)'; ...
            '*.png', 'Portable Network Graphics (*.png)'}, ...
            'Save MASK of selected series to files', ...
            [obj.sPath, filesep, '%SeriesName%_%ImageNumber%_Mask']);
          if isnumeric(sPath), return, end;   % Dialog aborted
          
          obj.sPath = sPath;
          fSaveMaskToFiles(sFilename, sPath);
        end
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Determine the NUMBER OF PANELS and their LAYOUT
      case 'tiles'
        dPos = get(obj.hF, 'CurrentPoint');
        dStartY = dPos(2);
        
        set(obj.SImgs.hUtil, 'Visible', 'on', 'CData', dGridImg, 'AlphaData', 0.5, 'UserData', 1);
        set(obj.SAxes.hUtil, 'XLim', [0.5 obj.iMAXVIEWS + 0.5], 'YLim', [0.5, obj.iMAXVIEWS + 0.5]);
        for iSize = fExpAnimation(10, 1, 120)
          dPos(2) = dStartY - iSize;
          dPos(3) = iSize;
          dPos(4) = iSize;
          set(obj.SAxes.hUtil, 'Position', dPos);
          drawnow update
          pause(0.01);
        end
        set(obj.hF, 'WindowButtonMotionFcn', @obj.utilMove);
        set(obj.hF, 'WindowButtonDownFcn', @obj.utilDown);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % RESET the TILE SIZES
      case 'equal_tiles'
        obj.dColWidth       = [1 1 1 1 1 1];
        obj.dRowHeight      = [1 1 1 1 1 1];
        obj.resize;
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Select the COLORMAP
      case 'colormap'
        dPos = get(obj.hF, 'CurrentPoint');
        dStartY = dPos(2);
        
        dColormapImg = obj.getColormapImg(obj.getColormaps);
        set(obj.SImgs.hUtil, 'Visible', 'on', 'CData', dColormapImg, 'UserData', 2, 'AlphaData', 0.5);
        set(obj.SAxes.hUtil, 'XLim', [0.5 size(dColormapImg, 2) + 0.5], 'YLim', [0.5, size(dColormapImg, 1) + 0.5]);
        for iSize = fExpAnimation(10, 1, round(size(dColormapImg, 2).*8))
          dPos(2) = dStartY - iSize;
          dPos(3) = 256;
          dPos(4) = iSize;
          set(obj.SAxes.hUtil, 'Position', dPos);
          drawnow update
          pause(0.01);
        end
        set(obj.hF, 'WindowButtonMotionFcn', @obj.utilMove);
        set(obj.hF, 'WindowButtonDownFcn', @obj.utilDown);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % RESET the view (zoom/window/center)
      case 'reset' % Reset the view properties of all data
        for iI = 1:length(obj.SData)
          obj.SData(iI).dZoom = 1;
          obj.SData(iI).dWindowCenter = double(mean(obj.SData(iI).dDynamicRange));
          obj.SData(iI).dWindowWidth = double(obj.SData(iI).dDynamicRange(2) - obj.SData(iI).dDynamicRange(1));
          obj.SData(iI).dDrawCenter = size(obj.SData(iI).dImg)./2;
        end
        obj.tooltip('100 %');
        obj.position;
        obj.draw;
        obj.grid;
        
      case 'export_img'
        [sFilename, sPath] = uiputfile('*.tif', 'Save Image', [obj.sPath, filesep, 'Image.tif']);
        if isnumeric(sPath), return, end
        
        sFilename = [sPath, sFilename];
        
        %         SParams = fExportDlg;
        
        %                 csTopLeft = get(obj.STexts.hView, 'Visible');
        %                 set(obj.STexts.hView, 'Visible', 'off');
        
        %                 set(obj.hF, 'Color', 'w');
        %                 set(obj.SAxes.hView, 'XColor', 'w', 'YColor', 'w');
        
        iImg = obj.screenshot;
        dImg = double(iImg)./255;
        
        %                 set(obj.SAxes.hView, 'XColor', obj.dBGCOLOR, 'YColor', obj.dBGCOLOR);
        %                 set(obj.hF, 'Color', obj.dBGCOLOR);
        
        dWidth = 8/2.54.*300;
        dFactor = dWidth./size(dImg, 2);
        
        dImg = imresize(dImg, dFactor, 'nearest');
        
        % -----------------------------------------------------------------
        % Overlay the letters/numbering
        iCols = size(obj.SView, 1);
        iRows = size(obj.SView, 2);
        dWidth  = obj.dColWidth(1:iCols);
        dWidth  = dWidth./sum(dWidth);
        dHeight = obj.dRowHeight(1:iRows);
        dHeight = dHeight./sum(dHeight);
        
        dLabels = fGetLetterGraphic('%A', iCols.*iRows, 12/72*300);
        [iH, iW] = size(dLabels(:,:,1));
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Apply to the image
        iInd = 1;
        for iY = 1:iRows
          
          iYPos = round(sum(dHeight(1:iY)).*size(dImg, 1)) - 10 - iH;
          
          for iX = 1:iCols
            iXPos = round(sum(dWidth(1:iX - 1)).*size(dImg, 2)) + 10;
            
            dImg(iYPos:iYPos + iH - 1, iXPos:iXPos + iW - 1, :) = fBlend(...
              dImg(iYPos:iYPos + iH - 1, iXPos:iXPos + iW - 1, :), [1 1 1], ...
              'Normal', dLabels(:,:,iInd));
            iInd = iInd + 1;
          end
        end
        % -----------------------------------------------------------------
        
        
        % -----------------------------------------------------------------
        % Save image
        iImg = uint8(dImg.*255);
        imwrite(iImg, sFilename, 'Resolution', 300, 'Description', 'Made with Imagine');
        % -----------------------------------------------------------------
        
      case {'export_gif_ab', 'export_gif_aba'}
        [sFilename, sPath] = uiputfile('*.gif', 'Save Animation', [obj.sPath, filesep, 'Animation.gif']);
        if isnumeric(sPath), return, end
        
        sFilename = [sPath, sFilename];
        
        iNTime = size(obj.SData(obj.iStartSeries).dImg, 5);
        iTInd = 1:iNTime;
        if strcmp(obj.SMenu(iInd).Name, 'export_gif_aba')
          iTInd = [iTInd, iNTime - 1:-1:2];
        end
        
        set(obj.STimers.hToolTip, 'StartDelay', 5);
        
        for iI = iTInd
          for iData = 1:length(obj.SData)
            obj.SData(iData).dDrawCenter(5) = min(iI, size(obj.SData(iData).dImg, 5));
          end
          
          obj.draw(1);
          obj.showPosition('time');
          drawnow
          
          iImg = obj.screenshot;
          [iImg, iMap] = rgb2ind(iImg, 256);
          if iI == 1
            imwrite(iImg, iMap, sFilename, 'gif', 'LoopCount' ,Inf,      'DelayTime', 0.1);
          else
            imwrite(iImg, iMap, sFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
          end
        end
        for iData = 1:length(obj.SData)
          obj.SData(iData).iTimePoint = 1;
        end
        obj.draw(1);
        
        stop(obj.STimers.hToolTip);
        set(obj.STimers.hToolTip, 'StartDelay', 0.8);
        start(obj.STimers.hToolTip);
        
      case 'Register'
        csRegs = obj.getRegistrations;
        if ~any(strcmp(sLabel, csRegs)), return, end
        
        sPath = fileparts(mfilename('fullpath'));
        sRegPath = [sPath, filesep, 'registration'];
        sElastixParamFile = [sRegPath, filesep, 'register_', sLabel, '.txt'];
        sImgName = [sRegPath, filesep, 'Image.mhd'];
        sMaskName = [sRegPath, filesep, 'Mask.mhd'];
        
        iData = obj.view2Series(obj.SAction.iStartView);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Get the image and prepare for writing to disk
        dImg = double(permute(obj.SData(iData).dImg(:,:,1,:,1), [1 2 4 3 5]));
        dImg = dImg - min(dImg(:));
        SImg.data = uint16(dImg./max(dImg(:)).*(2^16 - 1));
        SImg.size = size(dImg);
        SImg.orientation = eye(3);
        SImg.spacing = obj.SData(iData).dRes([1 2 4]);
        SImg.origin = obj.SData(iData).dOrigin([1 2 4]);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Get the image and prepare for writing to disk
        dMask = double(permute(obj.SData(iData).xMask(:,:,1,:,1), [1 2 4 3 5]));
        dMask = dMask - min(dMask(:));
        SMask.data = uint16(dMask./max(dMask(:)).*(2^16 - 1));
        SMask.size = size(dMask);
        SMask.orientation = eye(3);
        SMask.spacing = obj.SData(iData).dMaskResolution([1 2 4]);
        SMask.spacing = SMask.spacing(:)';
        SMask.origin = obj.SData(iData).dMaskOrigin([1 2 4]);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Write a file for each respiratory state
        write_mhd(sImgName, SImg, 'ElementType', 'int16');
        write_mhd(sMaskName, SMask, 'ElementType', 'int16');
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Do the registration and read back the data into SDeform (forward and backwards)
        system(sprintf('/elastix/bin/elastix -f %s -m %s -out %s -p %s', sImgName, sMaskName, sRegPath, sElastixParamFile));
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Retreive the transformation (shift) parameters
        sFilename = [sRegPath, filesep, 'TransformParameters.0.txt'];
        fid = fopen(sFilename);
        if fid == -1, error('No transformation information found!'); end
        lFound = false;
        while ~lFound && ~feof(fid);
          sLine = fgetl(fid);
          if strfind(sLine, 'TransformParameters')
            dShift = sscanf(sLine, '%*s %f %f %f %*s');
            lFound = true;
          end
        end
        fclose(fid);
        dShift = dShift(:)';
        dShift(4) = dShift(3);
        obj.SData(iData).dMaskOrigin = obj.SData(iData).dMaskOrigin - dShift;
        obj.draw;
        obj.position;
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
        
      case 'tag'
        iData = obj.SAction.SView.iData;
        %                 iDim = flip(obj.view2Orientation(obj.SAction.iStartView), 2);
        
        sRes = sprintf('%4.2f x ', obj.SData(iData).dRes([1 2 4]));
        sOrg = sprintf('%4.2f x ', obj.SData(iData).dOrigin([1 2 4]));
        csVal = {obj.SData(iData).sName, sRes(1:end-3), sOrg(1:end-3), obj.SData(iData).sUnits};
        
        csAns = inputdlg({'Name', 'Resolution', 'Origin', 'Units'}, sprintf('Change %s', obj.SData(iData).sName), 1, csVal);
        if isempty(csAns), return, end
        
        sName = csAns{1};
        obj.SData(iData).sName = sName;
        obj.SData(iData).dRes([1 2 4])     = cell2mat(textscan(csAns{2}, '%fx%fx%f'));
        obj.SData(iData).dOrigin([1 2 4])  = cell2mat(textscan(csAns{3}, '%fx%fx%f'));
        obj.SData(iData).sUnits = csAns{4};
        
        obj.draw;
        obj.position;
        obj.grid;
        % End of the TAG tool
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
      otherwise
    end
    
    
    % End of NORMAL buttons
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % TOGGLE buttons: Invert the state
  case 0
    obj.SMenu(iInd).Active = ~obj.SMenu(iInd).Active;
    
    switch(obj.SMenu(iInd).Name)
      
      case 'hd'
        obj.draw;
        
      case 'dock'
        if strcmp(get(obj.hF, 'WindowStyle'), 'docked')
          set(obj.hF, 'WindowStyle', 'normal');
        else
          set(obj.hF, 'WindowStyle', 'docked');
        end
        
      case 'datawindow'
        if isempty(obj.hDataWindow) || ~ishandle(obj.hDataWindow)
          obj.hDataWindow = iDataWindow(obj);
          addlistener(obj.hDataWindow, 'update', @obj.draw);
        end
        
        
      case '3d'
        obj.l3D = obj.isOn('3d');
        %                 if obj.isOn('3d')
        obj.hViews.setAxes;
        %                 else
        %                     obj.setViews([obj.iPanelsr(1) ceil(obj.iPanels(2)/3)]);
        %                 end
        
    end
    % End of TOGGLE buttons
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % The draw mode group
  case 1 % The draw mode group
    
    % Only activate source if it has been inactive (this radio group
    % allows all switches to be off, which means magnitude mode)
    if obj.SMenu(iInd).Active;
      sDrawMode = 'mag';
    else
      sDrawMode = obj.SMenu(iInd).Name;
    end
    
    % Update data structures with current draw mode
    obj.hData.sDrawMode = sDrawMode;
    
    fRadioGroup(obj, 1, sDrawMode);
    obj.draw;
    
  case 255 % The toolbar
    
    %         hLines = [obj.SView.hLine];
    %         set(hLines, 'Visible', 'off');
    %         obj.sROIMode = 'none';
    fRadioGroup(obj, 255, obj.SMenu(iInd).Name);
    % -   -   -   -   -   -   -   -   -   -   -   -   -
    
  case 256
    fRadioGroup(obj, 256, obj.SMenu(iInd).Name);
    
end
% -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

obj.updateActivation;
% -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -





function fRadioGroup(obj, iInd, sActivate)
for iI = find([obj.SMenu.GroupIndex] == iInd)
  obj.SMenu(iI).Active = strcmp(obj.SMenu(iI).Name, sActivate);
end





