classdef iData < handle
    
    properties
        Parent
        
        Img             = []
        Name            = ''
        Res             = ones(1, 3)
        Origin          = ones(1, 3)
        Units           = 'px'
        
        Mode            = 'scalar'
        
        
%         Zoom            = 1
%         Invert          = [0 0 0 0]
%         Dims            = [1 2 4; 1 4 2; 4 2 1]
        Orientation     = 'logical'
    end
    
    properties(Access = private)
        
    end
    
    methods
        
        function obj = iData(hImagine)
            obj.Parent = hImagine;
            
        end
    
    end
end