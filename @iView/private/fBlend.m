function dOut = fBlend(dBot, dTop, sMode, dAlpha)

% -------------------------------------------------------------------------
% Parse the inputs
if nargin < 4, dAlpha = 1.0; end % Top is fully opaque
if nargin < 3, sMode = 'overlay'; end
if nargin < 2, error('At least 2 input arguments required!'); end
if isa(dBot, 'uint8')
    dBot = double(dBot);
    dBot = dBot./255;
end
if isa(dTop, 'uint8')
    dTop = double(dTop);
    dTop = dTop./255;
end
% -------------------------------------------------------------------------

% Check Inputs
if numel(dTop) == 3
%     if isscalar(dAlpha), error('If top layer is given as a color, alpha map must be supplied!'); end
    dTop = repmat(permute(dTop(:), [3 2 1]), [size(dAlpha) 1]);
end
dTopSize = [size(dTop, 1), size(dTop, 2), size(dTop, 3), size(dTop, 4)];


% Check if background is monochrome
if numel(dBot) == 1 % grayscale background
    dBot = dBot.*ones(dTopSize);
end
if numel(dBot) == 3 % rgb background color
    dBot = repmat(permute(dBot(:), [2 3 1]), [dTopSize(1), dTopSize(2), 1, dTopSize(4)]);
end

dBotSize = [size(dBot, 1), size(dBot, 2), size(dBot, 3), size(dBot, 4)];
if dBotSize(3) ~= 1 && dBotSize(3) ~= 3, error('Bottom layer must be either grayscale or RGB!'); end
if dTopSize(3) > 4, error('Size of 3rd top layer dimension must not exceed 4!'); end
if any(dBotSize(1, 2) ~= dTopSize(1, 2)), error('Size of image data does not match'); end

if dBotSize(4) ~= dTopSize(4)
    if dBotSize(4) > 1 && dTopSize(4) > 1, error('4th dimension of image data mismatch!'); end
    
    if dBotSize(4) == 1, dBot = repmat(dBot, [1, 1, 1, dTopSize(4)]); end
    if dTopSize(4) == 1, dTop = repmat(dTop, [1, 1, 1, dBotSize(4)]); end
end

%% Handle the alpha map
if dTopSize(3) == 2 || dTopSize(3) == 4 % Alpha channel included
    dAlpha = dTop(:,:,end, :);
    dTop   = dTop(:,:,1:end-1,:);
else
    if isscalar(dAlpha)
        dAlpha = dAlpha.*ones(dTopSize(1), dTopSize(2), 1, dTopSize(4));
    else
        dAlphaSize = [size(dAlpha, 1), size(dAlpha, 2), size(dAlpha, 3), size(dAlpha, 4)];
        if any(dAlphaSize(1:2) ~= dTopSize(1:2)), error('Top layer alpha map dimension mismatch!'); end
        if dAlphaSize(3) > 1, error('3rd dimension of alpha map must have size 1!'); end
        if dAlphaSize(4) > 1
            if dAlphaSize(4) ~= dTopSize(4), error('Alpha map dimension mismatch!'); end
        else
            dAlpha = repmat(dAlpha, [1, 1, 1, dTopSize(4)]);
        end
    end
end

% Bring data into the right format
dMaxDim = max([size(dBot, 3), size(dTop, 3)]);
if dMaxDim > 2, lRGB = true; else lRGB = false; end

if lRGB && dBotSize(3) == 1, dBot = repmat(dBot, [1, 1, 3, 1]); end
if lRGB && dTopSize(3) == 1, dTop = repmat(dTop, [1, 1, 3, 1]); end
if lRGB, dAlpha = repmat(dAlpha, [1, 1, 3, 1]); end

% Check Range
dBot = fCheckRange(dBot);
dTop = fCheckRange(dTop);
dAlpha = fCheckRange(dAlpha);

% Do the blending
switch lower(sMode)
    case 'normal',      dOut = dTop;
    case 'multiply',    dOut = dBot.*dTop;
    case 'screen',      dOut = 1 - (1 - dBot).*(1 - dTop);
    case 'overlay'
        lMask = dBot < 0.5;
        dOut = 1 - 2.*(1 - dBot).*(1 - dTop);
        dOut(lMask) = 2.*dBot(lMask).*dTop(lMask);
    case 'hard_light'
        lMask = dTop < 0.5;
        dOut = 1 - 2.*(1 - dBot).*(1 - dTop);
        dOut(lMask) = 2.*dBot(lMask).*dTop(lMask);
    case 'soft_light',  dOut = (1 - 2.*dTop).*dBot.^2 + 2.*dTop.*dBot; % pegtop
    case 'darken',      dOut = min(cat(4, dTop, dBot), [], 4);
    case 'lighten',     dOut = max(cat(4, dTop, dBot), [], 4);
    otherwise,          error('Unknown blend mode ''%s''!', sMode);
end
dOut = dAlpha.*dOut + (1 - dAlpha).*dBot;

dOut(dOut > 1) = 1;
dOut(dOut < 0) = 0;


function dData = fCheckRange(dData)
dData(dData < 0) = 0;
dData(dData > 1) = 1;

  