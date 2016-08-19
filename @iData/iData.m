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
        
    end
    
    methods (Access = private)
        parseInputs(obj, varargin)
        
        function d3Lim_px = getSliceLim(obj, d3Lim_mm, iDim)
%             d3Lim_px = min(max(round((d3Lim_mm - obj.Origin(iDim(3)))./obj.Res(iDim(3)) + 1), 1), size(obj.Img, iDim(3)));
            d3Lim_px = round((d3Lim_mm - obj.Origin(iDim(3)))./obj.Res(iDim(3)) + 1);
            d3Lim_px = d3Lim_px(1):d3Lim_px(2);
            d3Lim_px = d3Lim_px(d3Lim_px > 0 & d3Lim_px < size(obj.Img, iDim(3)));
        end
    end
end