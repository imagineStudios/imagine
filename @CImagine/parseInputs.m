function parseInputs(obj, varargin)
%IMAGINE.PARSEINPUTS Breaks down the inputs into subsets to pass to PLUS
%
% The IMAGINE input format is:
% imagine(data1, 'Prop1_1', 'val1_1', ..., data2, 'Prop2_1', 'val2_1', ...);
% This function breaks the argunemts down into the data variable and all
% the associated (following) property-value pairs and passes all such sets
% of arguments to the PLUS routine.

iStart = 1;     % Index of the first argument of the current set of arguments
iInd = 1;       % Current argument index

% -------------------------------------------------------------------------
% Loop over all input arguments
while iInd <= length(varargin)
    
    if ischar(varargin{iInd})
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Name-Value pair coming up
        if length(varargin) == iInd
            error('Input %d ''%s'' must be followed by a value!', iInd, varargin{iInd})
        end
        iInd = iInd + 2;
        
    else
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % A new image coming up
        
        % Add the last dataset to imagine
        if iInd > iStart
            obj.plus(varargin{iStart:iInd-1});
        end
        
        iStart = iInd;
        iInd = iInd + 1;
        
    end
end

% -------------------------------------------------------------------------
% Add the latest dataset to imagine
if iInd > iStart
    obj.plus(varargin{iStart:iInd-1});
end