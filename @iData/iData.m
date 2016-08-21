classdef iData < handle
    
    properties
        Parent          = imagine.empty
        Img             = []
        Name            = ''
        Res             = ones(1, 5)
        Origin          = ones(1, 5)
        SpatialUnits    = 'px'
        TemporalUnits   = ''
        Mode            = 'scalar'
        Invert          = [0 0 0]
        Dims            = [1 2 3; 1 3 2; 3 2 1]
        Orientation     = 'logical'
        
        WindowCenter
        WindowWidth
        
        dColormap
        
        Hist
        HistCenter
    end
    
    properties(Access = private)
        hListeners
    end
    
    methods
        
        function obj = iData(hImagine, varargin)
            
            obj.Parent = hImagine;
            obj.parseInputs(varargin{:});
            
            obj.dColormap = gray(256);
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Make sure data object is deleted if imagine is closed
            obj.hListeners = addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
        end
        
        function delete(obj, ~, ~)
            delete([obj.hListeners]);
            delete@handle(obj);
        end
        
        [dImg, dXData, dYData] = getData(obj, dDrawCenter, iDimInd, lHD)
        iSize = getSize(obj)
        dCenter = getCenter(obj)
        
        d3Lim_px = getSliceLim(obj, dDrawCenter, iDim)
        
    end
    
    methods (Access = private)
        parseInputs(obj, varargin)
    end
end