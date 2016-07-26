function parseInputs(obj, varargin)

iStart = 1;
iInd = 2;
while iInd <= length(varargin)
    if ischar(varargin{iInd})
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Name-Value pair coming up
        if length(varargin) == iInd
            error('Input %d "%s" must be followed by a value!', iInd, varargin{iInd})
        end
        iInd = iInd + 2;
        
    else
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % A new image coming up, add the last to the data
        obj.plus(varargin{iStart}, varargin{iStart + 1:iInd-1});
        iStart = iInd;
        iInd = iInd + 1;
        
    end
end
obj.plus(varargin{iStart}, varargin{iStart + 1:iInd-1});