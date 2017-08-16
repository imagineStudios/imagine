classdef CData < handle
  
  properties
    
    Name            = ''
    SpatialUnits    = 'px'
    TemporalUnits   = ''
    Type            = 'scalar'
    Orientation     = 'native'
    ThumbSlice      = 1
    Alpha           = 1
    Views           = [];
    Res             = ones(1, 4)
    Origin          = ones(1, 4)
    
    Window
    
    Colormap
    
    Hist
    HistCenter
    
  end
  
  properties(Access = private)
    Img             = []
    Parent          = CImagine.empty()
    hListeners
    OldCenter
    OldWidth
    Colormaps
    
    B = [0 1 0; 0 0 1; -1 0 0] % Transformation matrix from data to xyz for native data format
  end
  
  methods
    
    function obj = CData(hImagine, iInd, varargin)
      
      obj.Parent = hImagine;
      obj.parseInputs(varargin{:});
      if isempty(obj.Name)
        obj.Name = sprintf('Data %d', iInd);
      end
      
      obj.ThumbSlice = round(size(obj.Img, 3)./2);
      obj.setColormap('Gray');
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % Make sure data object is deleted if imagine is closed
      obj.hListeners = addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
    end
    
    function delete(obj, ~, ~)
      delete([obj.hListeners]);
      delete@handle(obj);
    end
    
    [dImg, dXData, dYData, dAlpha] = getData(obj, dDrawCenter, dA, hAxes)
    [dUData, dVData, dXData, dYData, dCData] = getVectors(obj, dDrawCenter, iDimInd, hA)
    
    setColormap(obj, xMap)
    [sMap, iInd] = getColormap(obj)
    
    iSize_xyz = getSize(obj, iDim)
    dCoverage = getCoverage(obj, iDim)
    dCenter = getCenter(obj)
    
    d3Lim_px = getSliceLim(obj, dDrawCenter, iDim)
    
    function iPermutation = getPermutation(obj)
       iPermutation = obj.B*[1 2 3]';
    end
    
    backup(obj)
    window(obj, dFactor)
    
    function dXYZ = mno2xyz(obj, iMNO)
      dMNO = (iMNO - 1).*obj.Res(1:3) + obj.Origin(1:3); % Scaling
      dXYZ = (abs(obj.B)*dMNO')';      % Permutation
    end
    
    function iMNO = xyz2mno(obj, dXYZ)
      dMNO = abs(obj.B')*dXYZ';       % Permutation
      iMNO = round( (dMNO' - obj.Origin(1:3))./obj.Res(1:3) ) + 1; % Scaling
    end
    
    function cRes = getRes(obj)
      cRes = cell2mat({obj.Res}');
    end
    
    setOrientation(obj, sOrientation)
    
  end
  
  methods (Access = private)
    parseInputs(obj, varargin)
  end
  
end