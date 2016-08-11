classdef iView < handle
    
    properties
        Parent
    end
    
    properties(SetObservable = true)
        Position
    end
    
    properties (Access = private)
        hA          % Axes
        hI          % Image components
        hQ          % Quiver components
        hL          % Line components
        hS          % Scatter components
        hT          % Text components
        
        iInd        = 0
        iData       = [];
        iDimInd     = 1;
        
        hListener
        
    end
    
    methods
        function obj = iView(hImagine, iInd)
            
            obj.Parent = hImagine;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % View axes and its children
            obj.hA = axes(...
                'Parent'            , hImagine.hF, ...
                'Layer'             , 'top', ...
                'Units'             , 'pixels', ...
                'Color'             , 'k', ...
                'FontSize'          , 12, ...
                'XTickMode'         , 'manual', ...
                'YTickMode'         , 'manual', ...
                'XColor'            , [0.5 0.5 0.5], ...
                'YColor'            , [0.5 0.5 0.5], ...
                'XTickLabelMode'    , 'manual', ...
                'YTickLabelMode'    , 'manual', ...
                'XAxisLocation'     , 'top', ...
                'YDir'              , 'reverse', ...
                'Box'               , 'on', ...
                'HitTest'           , 'on', ...
                'XGrid'             , 'off', ...
                'YGrid'             , 'off', ...
                'XMinorGrid'        , 'off', ...
                'YMinorGrid'        , 'off');
            hold on
            
            obj.hI = image( ...
                'Parent'                , obj.hA, ...
                'CData'                 , zeros(1, 1, 3), ...
                'HitTest'               , 'off');
            
            try set(obj.hA, 'YTickLabelRotation', 90); end
            
            obj.iInd = iInd;
            
            uistack(obj.hA, 'bottom');
            
            obj.hListener = addlistener(obj, 'Position', 'PostSet', @obj.setPosition);
            obj.hListener(1) = addlistener(hImagine, 'viewImageChange', @obj.draw);
        end
        
    end
    
    methods(Access = private)
        
        setPosition(obj, ~, ~)
        draw(obj, ~, ~)
        position(obj, ~, ~)
        
    end
end
