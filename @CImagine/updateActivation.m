function updateActivation(obj)

dDISABLED_SCALE         = 0.25;     % Brightness of disabled buttons (decrease to make darker)
dINACTIVE_SCALE         = 0.5;      % Brightness of inactive buttons (toggle buttons and radio groups)

persistent cIcons
persistent cIconsScaled

cIcons = [];
if isempty(cIcons)
  cIcons = fGetIcons(obj);
end

if isempty(cIconsScaled)
  cIconsScaled = fScaleIcons(obj, cIcons);
end

if size(cIconsScaled{1}, 1) ~= obj.iIconSize
  cIconsScaled = fScaleIcons(obj, cIcons);
end

% -------------------------------------------------------------------------
% Treat the menubar items
dAlphaScale = ones(1, length(obj.SMenu));
dAlphaScale(~[obj.SMenu.Enabled])                        = dDISABLED_SCALE;
dAlphaScale( [obj.SMenu.Enabled] & ~[obj.SMenu.Active] & [obj.SMenu.GroupIndex] > 0)  = dINACTIVE_SCALE;
dAlphaScale(strcmp({obj.SMenu.Name}, 'dock')) = 1;

iToolYStart = 1;
iMenuXStart = 1;
iContextInd = 1;
for iI = find([obj.SMenu.GroupIndex] ~= 256)
  
  dImg = cIconsScaled{iI};
  if obj.SMenu(iI).GroupIndex == 0 && obj.SMenu(iI).Active
    dImg = dImg(:,:,:,2);
  else
    dImg = dImg(:,:,:,1);
  end
  
  
  if ~obj.SMenu(iI).SubGroupInd
    
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Normal buttons in menubar or toolbar
    switch obj.SMenu(iI).GroupIndex
      
      % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
      % Toolbar
      case 255
        dXData = 1;
        dYData = 1 + iToolYStart;
        iToolYStart = iToolYStart - 4 + obj.iIconSize;
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Menubar
      otherwise
        dXData = 1 + iMenuXStart + 12.*obj.SMenu(iI).Spacer;
        dYData = 1;
        iMenuXStart = iMenuXStart + obj.iIconSize - 4 + 12.*obj.SMenu(iI).Spacer;
    end
    
  else
    
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % The context menu
    dXData = 1;
    dYData = 1 + iContextInd;
    iContextInd = iContextInd + obj.iIconSize;
  end
  
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Dock button
  if strcmp(obj.SMenu(iI).Name, 'dock')
    dPos = get(obj.SAxes.hMenu, 'Position');
    dXData = dPos(3) - obj.iIconSize;
    dYData = 1;
  end
  
  set(obj.SImgs.hIcons(iI), ...
    'CData'         , dImg(:,:,1:3), ...
    'AlphaData'     , dImg(:,:,4).*dAlphaScale(iI), ...
    'XData'         , dXData, ...
    'YData'         , dYData, ...
    'Visible'       , 'on');
  
end
% -------------------------------------------------------------------------


function cIcons = fGetIcons(obj)

sIconPath = [obj.sBasePath, filesep(), '..', filesep(), 'themes', filesep(), obj.sTheme, filesep(), 'icons'];

% [~, ~, dImg] = imread([sIconPath, 'submenu.png']);
% dSub = double(repmat(dImg, [1 1 2]));

cIcons = cell(1, length(obj.SMenu));
for iI = 1:length(obj.SMenu)
  
  [dImg1, ~, dAlpha1] = imread([sIconPath, filesep(), obj.SMenu(iI).Name, '.png']); % icon file name (.png) has to be equal to icon name
  dImg1 = double( cat(3, dImg1, dAlpha1) )./255;
  
  if exist([sIconPath, filesep(), obj.SMenu(iI).Name, '1.png'], 'file')
    [dImg2, ~, dAlpha2] = imread([sIconPath, filesep(), obj.SMenu(iI).Name, '1.png']);
    dImg2 = double( cat(3, dImg2, dAlpha2) )./255;
  else
    dImg2 = rgb2gray(dImg1(:,:,1:3));
    dImg2 = cat(3, repmat(dImg2, [1 1 3]), dImg1(:,:,4)./2);
  end
  dImg = cat(4, dImg1, dImg2);
  
%   if obj.SMenu(iI).SubGroup, dImg = dImg + dSub; end
  cIcons{iI} = dImg;
end


function cIconsScaled = fScaleIcons(obj, cIcons)

cIconsScaled = cell(size(cIcons));
iSize = obj.iIconSize - 2.*obj.iICONPADDING;
for iI = 1:length(cIcons)
  dIcon = imresize(cIcons{iI}, [iSize iSize], 'bicubic');
  dIcon = padarray(dIcon, [obj.iICONPADDING, obj.iICONPADDING, 0, 0], 0, 'both');
  cIconsScaled{iI}(cIconsScaled{iI} < 0) = 0;
  cIconsScaled{iI}(cIconsScaled{iI} > 1) = 1;
  cIconsScaled{iI} = dIcon;
end
