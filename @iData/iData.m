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
        Invert          = [0 0 0 0]
        Dims            = [1 2 4; 1 4 2; 4 2 1]
        Orientation     = 'logical'
        
        WindowCenter
        WindowWidth
        
        dColormap
        
        Hist
        HistCenter
    end
    
    properties(Access = private)
        
    end
    
    methods
        
        function obj = iData(hImagine, varargin)
            
            obj.Parent = hImagine;
            obj.parseInputs(varargin{:});
            
            obj.dColormap = gray(256);
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Make sure data object is deleted if imagine is closed
            addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
        end
        
        function delete(obj, ~, ~)
            delete@handle(obj);
        end
        
        [dImg, dXData, dYData] = getData(obj, SView, iSeries, lHD)
        
        function dSize = getSize(obj)
            dSize = size(obj.Img);
        end
        
    end
    
    methods (Access = private)
        parseInputs(obj, varargin)
        
        function d3Lim_px = getSliceLim(obj, d3Lim_mm, iDim)
            d3Lim_px = min(max(round((d3Lim_mm - obj.Origin(iDim(3)))./obj.Res(iDim(3)) + 1), 1), size(obj.Img, iDim(3)));
        end
    end
end