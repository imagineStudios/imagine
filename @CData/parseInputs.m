function parseInputs(obj, varargin)

% -------------------------------------------------------------------------
% Process the first input, which has to contain the image data

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Validate data type
validateattributes(varargin{1}, {'numeric', 'logical', 'struct'}, {});

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% If it is a struct, process it into image data and cell of parameters
if length(varargin) > 1
  cParams = varargin(2:end);
else
  cParams = {};
end
  
if isstruct(varargin{1})
  [dImg, cAdditionalParams] = iGlobals.fStruct2Params(varargin{1});
  cParams = [cParams, cAdditionalParams];
else
  dImg = varargin{1};
end


% -------------------------------------------------------------------------
% Get the histogram and dynamic range from the input data
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
obj.Window(1) = obj.HistCenter(1);
obj.Window(2) = obj.HistCenter(end);
if diff(obj.Window) == 0, obj.Window(2) = obj.Window(1) + 1; end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Parse optional parameter-value pairs
hP = inputParser;

% hValidFcn = @(x) validatestring(x, {'scalar', 'categorical', 'rgb', 'vector'});
hP.addParameter('Name', '', @ischar);
hP.addParameter('Resolution', []);
hP.addParameter('Origin', []);
hP.addParameter('Units', 'px', @ischar);
hP.addParameter('TemporalUnits', '', @ischar);

hP.addParameter('Mode', '');

hP.addParameter('Orientation', 'physical', @ischar);
hP.addParameter('Source', 'startup', @ischar);

hP.addParameter('Window', []);
hP.addParameter('Views', []);
hP.addParameter('Alpha', 1);

hP.parse(cParams{:});

sMode = hP.Results.Mode;
obj.Name = hP.Results.Name;
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Figure out data type and do necessary permutation
lReal = isreal(dImg);
switch ndims(dImg)
  
  case 2
    if strcmpi(sMode, 'rgb') || strcmpi(sMode, 'vector')
      error('2D data connot be RGB or Vector data!');
    end
    if isempty(sMode), sMode = 'scalar'; end
    obj.Img = dImg;
    obj.Mode = sMode;
    
  case 3
    if size(dImg, 3) == 3 && ~(strcmp(sMode, 'scalar') || strcmp(sMode, 'categorical')) && lReal % Assume RGB data
      if isempty(sMode), sMode = 'rgb'; end
      obj.Img = permute(dImg, [1 2 5 4 3]);
      obj.Mode = sMode;
    else
      if strcmpi(sMode, 'rgb') || strcmpi(sMode, 'vector')
        error('Data is declared RGB or Vector, but 3rd dimension is not of size 3!');
      end
      if isempty(sMode), sMode = 'scalar'; end
      obj.Img = dImg;
      obj.Mode = sMode;
    end
    
  case 4
    if size(dImg, 3) == 3 && ~(strcmp(sMode, 'scalar') || strcmp(sMode, 'categorical')) && lReal % Assume RGB Video
      if isempty(sMode), sMode = 'rgb'; end
      obj.Img = permute(dImg, [1 2 5 4 3]);
      obj.Mode = sMode;
    else
      if strcmpi(sMode, 'rgb') || strcmpi(sMode, 'vector')
        error('Data is declared RGB or Vector, but 3rd dimension is not of size 3!');
      end
      if isempty(sMode), sMode = 'scalar'; end
      obj.Img = dImg;
      obj.Mode = sMode;
    end
    
  case 5 % can only be 3D Vector data
    if strcmp(sMode, 'scalar') || strcmp(sMode, 'categorical')
      error('5D data can only be of type RGB or vector!');
    end
    if ~lReal
      error('5D data must be real!');
    end
    i3Ind = size(dImg) == 3;
    i3Ind = i3Ind(i3Ind > 2);
    switch length(i3Ind)
      case 0
        error('5D data supplied, but no dimension is of size 3!');
      
      case 1
        iPermutation = [1 2 3 4 d3Ind];
        iPermutation(d3Ind) = 5;
        obj.Img = permute(dImg, iPermutation);
        
      otherwise
        if any(i3Ind == 5)
          obj.Img = dImg;
        else % (3 or 4)
          obj.Img = permute(dImg, [1 2 3 5 4]);
        end
    end
    if isempty(sMode), sMode = 'vector'; end
    obj.Mode = sMode;
    
  otherwise
    error('Allowed number of input dimensions is 2-5');
    
end
  
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
    obj.Origin = hP.Results.Origin(:)';
  end
  if isempty(hP.Results.Units)
    obj.SpatialUnits = 'px';
  else
    obj.SpatialUnits = hP.Results.Units;
  end
else
  obj.Res = hP.Results.Resolution(:)';
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Resolution given
  if isempty(hP.Results.Origin) % Assume user wants 0 as data origin
    obj.Origin = [0 0 0 0];
  else
    obj.Origin = hP.Results.Origin(:)';
  end
  if isempty(hP.Results.Units) % Assume mm resolution
    obj.SpatialUnits = 'mm';
  end
end

obj.Res    = padarray(obj.Res,    [0, 4 - length(obj.Res)],    1, 'post');
obj.Origin = padarray(obj.Origin, [0, 4 - length(obj.Origin)], 1, 'post');
% -------------------------------------------------------------------------