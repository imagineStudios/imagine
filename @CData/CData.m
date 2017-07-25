classdef CData < handle
    
    properties
        
        Name            = ''
        Res             = ones(1, 4)
        Origin          = ones(1, 4)
        SpatialUnits    = 'px'
        TemporalUnits   = ''
        Mode            = 'scalar'
        Invert          = [0 0 0]
        Dims            = [1 2 3; 1 3 2; 3 2 1]
        Orientation     = 'logical'
        ThumbSlice      = 1
        Alpha           = 1
        iViews          = [];
        sDrawMode       = 'mag';
        
        Window
        
        Colormap
        
        Hist
        HistCenter
        
%         CMapPreview
    end
    
    properties(Access = private)
        Img             = []
        Parent          = imagine.empty
        hListeners
        OldCenter
        OldWidth
        Colormaps
    end
    
    methods
        
        function obj = CData(hImagine, iInd, varargin)
            
            obj.Parent = hImagine;
            obj.parseInputs(varargin{:});
            if isempty(obj.Name)
                obj.Name = sprintf('Data %d', iInd);
            end
            
            obj.ThumbSlice = round(obj.getSize(3)./2);
            obj.setColormap(obj.Parent.SColormaps(1));
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Make sure data object is deleted if imagine is closed
            obj.hListeners = addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
        end
        
        function delete(obj, ~, ~)
            delete([obj.hListeners]);
            delete@handle(obj);
        end
        
        [dImg, dXData, dYData, dAlpha] = getData(obj, dDrawCenter, iDimInd, hA, lHD)
        [dUData, dVData, dXData, dYData, dCData] = getVectors(obj, dDrawCenter, iDimInd, hA)
        
%         setColormap(obj, sMap)
%         [sMap, iInd] = getColormap(obj)
        
        iSize = getSize(obj, iDim)
        dCoverage = getCoverage(obj, iDim)
        dCenter = getCenter(obj)
        
        d3Lim_px = getSliceLim(obj, dDrawCenter, iDim)
        
        backup(obj)
        window(obj, dFactor)
        
    end
    
    methods (Access = private)
        parseInputs(obj, varargin)
    end
    
%     methods (Static)
%         csColormaps = getColormaps
%         dPreview = getColormapPreview(csColormaps)
%     end
end