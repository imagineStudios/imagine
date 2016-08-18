function parseInputs(obj, varargin)

% -------------------------------------------------------------------------
% Process the first input, which has to contain the image data

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Validate data type
validateattributes(varargin{1}, {'numeric', 'logical', 'struct'}, {});

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% If it is a struct, process it into image data and cell of parameters
if isstruct(varargin{1})
    [dImg, cAdditionalInputs] = fStruct2Params(varargin{1});
    if nargin > 1
        cParams = [cAdditionalInputs, varargin(2:end)];
    else
        cParams = {};
    end
else
    dImg = varargin{1};
    if nargin > 1
        cParams = varargin(2:end);
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Check the image data for some stupid combinations
if isfloat(dImg)
    if size(dImg, 5) == 3 && ~isreal(dImg)
        error('Vector/rgb data must be real!');
    end
else
    if ~isreal(dImg), error('Integer data must be real!'); end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Check input dimensions
if ndims(dImg) > 5, error('Too many input dimensions!'); end
obj.Img = dImg;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Deduce the histogram and dynamic range from the input data
if isinteger(dImg)
    if numel(dImg) > 1E6
        [obj.Hist, obj.HistCenter] = hist(double(dImg(1:100:end)), 256);
    else
        [obj.Hist, obj.HistCenter] = hist(double(dImg(:)), 256);
    end
else
    if isreal(dImg)
        if numel(dImg) > 1E6
            [obj.Hist, obj.HistCenter] = hist(dImg(1:100:end), 256);
        else
            [obj.Hist, obj.HistCenter] = hist(dImg(:), 256);
        end
    else
        if numel(dImg) > 1E6
            [obj.Hist, obj.HistCenter] = hist(abs(dImg(1:100:end)), 256);
        else
            [obj.Hist, obj.HistCenter] = hist(abs(dImg(:)), 256);
        end
    end
end
dMin = obj.HistCenter(1);
dMax = obj.HistCenter(end);
obj.WindowCenter = double(dMin + dMax)./2;
obj.WindowWidth  = double(dMax - dMin);
if obj.WindowWidth == 0, obj.WindowWidth = 1; end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Parse optional parameter-value pairs
hP = inputParser;

hValidFcn = @(x) validatestring(x, {'scalar', 'categorical', 'rgb', 'vector'});
hP.addParameter('Mode', '', hValidFcn);

hP.addParameter('Source', '', @ischar);
hP.addParameter('Name', '', @ischar);
hP.addParameter('Units', 'px', @ischar);

hValidFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 3, 'positive'});
hP.addParameter('Resolution', [], hValidFcn);
hP.addParameter('Origin', []);
hP.addParameter('Window', []);
hP.addParameter('Orientation', 'physical', @ischar);
hP.addParameter('Views', []);

hP.parse(cParams{:});
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Handle the orientation data
obj.Orientation = validatestring(hP.Results.Orientation, {'transversal', 'coronal', 'physical', 'sagittal'});
switch (obj.Orientation)
    case 'transversal'
        obj.Dims = [1 2 3; 3 2 1; 3 1 2];
        obj.Invert = [0 0 1];
        
    case {'coronal', 'physical'}
        obj.Dims = [1 2 3; 1 3 2; 3 2 1];
        obj.Invert = [0 0 0];
        
    case {'sagittal'}
        obj.Dims = [1 2 3; 1 3 2; 2 3 1];
        obj.Invert = [0 0 0];
        
    otherwise
        error('Orientation must be either "tra", "cor" or "sag"!');
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Supplement the coordinate system data according to what's been supplied
if isempty(hP.Results.Resolution)
    if ~isempty(hP.Results.Origin)
        obj.Origin = hP.Results.Origin;
    end
    if isempty(hP.Results.Units)
        obj.SpatialUnits = 'px';
    else
        obj.SpatialUnits = hP.Results.Units;
    end
else
    obj.Res = hP.Results.Resolution;
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Resolution given
    if isempty(hP.Results.Origin) % Assume user wants 0 as data origin
        obj.Origin = [0 0 0 1 1];
    else
        obj.Origin = hP.Results.Origin;
    end
    if isempty(hP.Results.Units) % Assume mm resolution
        obj.SpatialUnits = 'mm';
    end
end

if length(obj.Res) < 5, obj.Res = padarray(obj.Res, [0, 5 - length(obj.Res)], 1, 'post'); end
if length(obj.Origin) < 5, obj.Origin = padarray(obj.Origin, [0, 5 - length(obj.Origin)], 1, 'post'); end
% -------------------------------------------------------------------------