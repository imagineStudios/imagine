classdef CComboBox < handle
  
  properties
    Imgs
    Alpha
    Labels
    Ind         = 0
    Position    = [1 1]
    Parent      = matlab.graphics.axis.Axes.empty()
    Callback    = function_handle.empty()
  end
  
  properties (Access = private)
    
    hI          = matlab.graphics.primitive.Image.empty()
    hA          = matlab.graphics.axis.Axes.empty()
    
    iWidth
    iHeight
    
    hListeners
    Tooltip
  end
  
  methods
    
    function obj = CComboBox(varargin)
      
      obj.parseInputs(varargin{:});
      obj.createGUIElements();
      
      % Create a stacked version of the icons and display in hidden image for selection
      dImg = reshape(permute(obj.Imgs(:,:,1:3,:), [1, 4, 2, 3]), [], size(obj.Imgs, 2), size(obj.Imgs, 3));
      dAlpha = reshape(permute(obj.Alpha(:,:,:,:), [1, 4, 2, 3]), [], size(obj.Alpha, 2), size(obj.Alpha, 3));
      obj.hI(2) = image( ...
        'Parent'            , obj.hA, ...
        'CData'             , dImg, ...
        'AlphaData'         , dAlpha, ...
        'Visible'           , 'off');
      
      obj.drawIcon;
      obj.setPosition;
      
      obj.hListeners    = addlistener(get(obj.Parent, 'Parent'), 'WindowMousePress'  , @obj.mouseDown);
      obj.hListeners(2) = addlistener(get(obj.Parent, 'Parent'), 'WindowMouseMotion' , @obj.mouseMove);
      obj.hListeners(2).Enabled = false;
      obj.hListeners(3) = addlistener(obj.Parent, 'ObjectBeingDestroyed' , @obj.delete);
    end
    
    
    function delete(obj, ~, ~)
      delete([obj.hA]);
      delete([obj.hListeners]);
      delete@handle(obj)
    end
    
    function setInd(obj, iInd)
      if ~isempty(iInd)
        if iInd > 0 && iInd <= size(obj.Imgs, 4)
          obj.Ind = iInd;
          obj.drawIcon();
        else
          error('Index exceeds combobox options!');
        end
      end
    end
    
  end
  
  
  methods (Access = private)
    
    function parseInputs(obj, varargin)
      hP = inputParser();
      
      hP.addParameter('Parent', matlab.graphics.axis.Axes.empty, @(x) isa(x, 'matlab.graphics.axis.Axes'));
      hP.addParameter('Imgs', 0, @(x) isnumeric(x));
      hValidFcn = @(x) validateattributes(x, {'numeric'}, {'scalar'});
      hP.addParameter('Ind', 1, hValidFcn);
      hValidFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 2});
      hP.addParameter('Position', [1 1], hValidFcn);
      hP.addParameter('Callback', function_handle.empty, @(x) isa(x, 'function_handle'));
      hP.addParameter('Alpha', 1, @(x) isnumeric(x));
      hP.addParameter('Labels', '', @(x) iscell(x));
      hP.addParameter('Tooltip', '', @(x) isa(x, 'iTooltip'));
      
      hP.parse(varargin{:});
      
      cFN = fieldnames(hP.Results);
      for iI = 1:length(cFN)
        obj.(cFN{iI}) = hP.Results.(cFN{iI});
      end
      
      if isempty(obj.Parent)
        obj.Parent = gca;
      end
      obj.iWidth = size(obj.Imgs, 2);
      obj.iHeight = size(obj.Imgs, 1);
      
      if isscalar(obj.Alpha)
        obj.Alpha = zeros(obj.iHeight, obj.iWidth, 1, size(obj.Imgs, 4)) + obj.Alpha;
      end
    end
    
    function createGUIElements(obj)
      hF = get(obj.Parent, 'Parent');
      
      obj.hA = axes( ...
        'Parent'            , hF, ...
        'Visible'           , 'off', ...
        'YDir'              , 'reverse', ...
        'XLim'              , [0, obj.iWidth] + 0.5, ...
        'Units'             , 'pixels', ...
        'Hittest'           , 'off');
      obj.hI(1) = image(...
        'Parent'            , obj.Parent, ...
        'CData'             , 0);
    end
    
    function mouseDown(obj, ~, ~)
      hOver = hittest();
      
      if hOver == obj.hI(1) % Click on the box
        if strcmp(obj.hI(2).Visible, 'on')
          obj.hide();
        else
          obj.show();
        end
        
      elseif hOver == obj.hI(2) % Click on the menu
        dPos = get(obj.hA, 'CurrentPoint');
        obj.Ind = ceil(dPos(1, 2)/obj.iHeight);
        obj.drawIcon();
        obj.Callback();
        
        obj.hide();
        
      else
        if strcmp(get(obj.hI(2), 'Visible'), 'on')
          obj.hide();
        end
      end
    end
    
    function mouseMove(obj, ~, ~)
      if strcmp(obj.hI(2).Visible, 'on')
        if hittest() == obj.hI(2) &&  ~isempty(obj.Labels) && ~isempty(obj.Tooltip)
          dPos = get(obj.hA, 'CurrentPoint');
          iInd = ceil(dPos(1, 2)/obj.iHeight);
          if iInd > 0 && iInd <= size(obj.Imgs, 4)
            obj.Tooltip.show(obj.Labels{iInd});          
          end
        end
      end
    end
    
    function show(obj)
      uistack(obj.hA, 'top');
        
        dPos = obj.Parent.Position;
        dYStart = dPos(2) + dPos(4) - obj.iHeight - obj.Position(2);
        
        dStartHeight  = 1;
        dTargetHeight = size(obj.Imgs, 1).*size(obj.Imgs, 4);
        
        dPos = [obj.Position(1) + dPos(1), dYStart, obj.iWidth, 1];
        set(obj.hI(2), 'Visible', 'on');
        
        for dVal = fExpAnimation(20, 1, 0);
          iH = round((1 - dVal)*dTargetHeight + dVal*dStartHeight);
          dPos(2) = dYStart - iH;
          dPos(4) = iH;
          set(obj.hA, ...
            'Position'  , [dPos(1), dYStart - iH, dPos(3), iH], ...
            'YLim'      , [0 iH] + 0.5);
          
          pause(0.01);
        end
        obj.hListeners(2).Enabled = true;
    end
    
    function hide(obj)
      dAlphaData = get(obj.hI(2), 'AlphaData');
      for dAlpha = 0.8:-0.1:0
        set(obj.hI(2), 'AlphaData', dAlpha.*dAlphaData);
        drawnow update
        pause(0.01);
      end
      
      set(obj.hI(2), 'Visible', 'off', 'AlphaData', dAlphaData);
      obj.hListeners(2).Enabled = false;
    end
    
    function setPosition(obj)
      set(obj.hI(1), 'XData', obj.Position(1), 'YData', obj.Position(2));
    end
    
    function drawIcon(obj)
      dImg = cat(3, obj.Imgs(:,:,:,obj.Ind), obj.Alpha(:,:,:,obj.Ind));
      dArrow = obj.getArrowImg;
      dArrow = imresize(dArrow, size(dImg(:,:,1)));
      dImg = fBlend(dImg, dArrow, 'normal');
      set(obj.hI(1), ...
        'CData'   , dImg(:,:,1:3), ...
        'AlphaData', dImg(:,:,4));
    end
    
  end
  
  methods (Static)
    
    function dImg = getArrowImg
      
      persistent dArrowImg
      
%       dArrowImg = [];
      if isempty(dArrowImg)
        sPath = fileparts(mfilename('fullpath'));
        [iImg, ~, iAlpha] = imread([sPath, filesep, 'arrow.png']);
        dArrowImg = double(cat(3, iImg, iAlpha))./255;
      end
      
      dImg = dArrowImg;
      
    end
    
  end
  
end
