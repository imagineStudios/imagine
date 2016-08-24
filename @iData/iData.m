classdef iData < handle
    
    properties
        Parent          = imagine.empty
        Img             = []
        Name            = ''
        Res             = ones(1, 4)
        Origin          = ones(1, 4)
        SpatialUnits    = 'px'
        TemporalUnits   = ''
        Mode            = 'scalar'
        Invert          = [0 0 0]
        Dims            = [1 2 3; 1 3 2; 3 2 1]
        Orientation     = 'logical'
        
        Window
        
        dColormap
        
        Hist
        HistCenter
    end
    
    properties(Access = private)
        hListeners
        OldCenter
        OldWidth
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
        
        [dImg, dXData, dYData] = getData(obj, dDrawCenter, iDimInd, hA, lHD)
        iSize = getSize(obj)
        dCenter = getCenter(obj)
        
        d3Lim_px = getSliceLim(obj, dDrawCenter, iDim)
        
        function backup(obj)
            for iI = 1:numel(obj)
                obj(iI).OldCenter = mean(obj(iI).Window);
                obj(iI).OldWidth  = obj(iI).Window(2) - obj(iI).Window(1);
            end
        end
        
        function window(obj, dFactor)
            for iI = 1:length(obj)
                dCenter = obj(iI).OldCenter.*exp(dFactor(1));
                dWidth  = obj(iI).OldWidth.*exp(-dFactor(2));
                obj(iI).Window = dCenter + 0.5.*[-dWidth, dWidth];
            end
        end
        
    end
    
    methods (Access = private)
        parseInputs(obj, varargin)
    end
end