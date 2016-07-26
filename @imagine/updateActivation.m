function updateActivation(obj)

dDISABLED_SCALE         = 0.25;     % Brightness of disabled buttons (decrease to make darker)
dINACTIVE_SCALE         = 0.5;      % Brightness of inactive buttons (toggle buttons and radio groups)
dCOLORLUT = 255 + zeros(10, 3);

persistent cIcons
persistent cIconsScaled

% cIcons = {};
% cIconsScaled = {};
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
iMenuXStart = obj.iIconSize;
iContextInd = 1;
for iI = find([obj.SMenu.GroupIndex] ~= 256)
%     dColor = repmat(permute([240 250 250], [1 3 2])/255, [obj.iIconSize, obj.iIconSize, 1]);
    dColor = repmat(permute(dCOLORLUT(obj.SMenu(iI).Color, :), [1 3 2])/255, [obj.iIconSize, obj.iIconSize, 1]);
    dImg = cIconsScaled{iI};
    if obj.SMenu(iI).GroupIndex == 0 && obj.SMenu(iI).Active
        dImg = dImg(:,:,2);
    else
        dImg = dImg(:,:,1);
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
        'CData'         , dColor, ...
        'AlphaData'     , dImg.*dAlphaScale(iI), ...
        'XData'         , dXData, ...
        'YData'         , dYData, ...
        'Visible'       , 'on');
    
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% The sidebar tabs (no change in icon size)
iSideInd = 1;
for iI = find([obj.SMenu.GroupIndex] == 256)
    
    set(obj.SImgs.hIcons(iI), ...
        'CData'     , cIcons{iI}(:,:,1:3), ...
        'AlphaData' , cIcons{iI}(:,:,4).*dAlphaScale(iI), ...  
        'XData'     , 1 + iSideInd, ...
        'YData'     , 1);
        iSideInd = iSideInd + 44;
end
% -------------------------------------------------------------------------

% obj.drawHistogram(1);


function cIcons = fGetIcons(obj)

sIconPath = [fileparts(mfilename('fullpath')), filesep, 'icons', filesep];

[~, ~, dImg] = imread([sIconPath, 'tab.png']);
dTab = double(dImg(15:62,9:68))./255;
dTab = imresize(dTab, [32, 48], 'bicubic');

[~, ~, dImg] = imread([sIconPath, 'submenu.png']);
dSub = double(repmat(dImg, [1 1 2]));

% [~, ~, dBox] = imread([sIconPath, 'square2.png']);
% dBox = double(repmat(dBox, [1 1 2]));

cIcons = cell(1, length(obj.SMenu));

dFade = repmat([linspace(1, 0.95, 42)'; linspace(0.75, 0.6, 34)'], [1 size(dImg, 2) 2]);

for iI = 1:length(obj.SMenu)
    
    [~, ~, dImg] = imread([sIconPath, obj.SMenu(iI).Name, '.png']); % icon file name (.png) has to be equal to icon name
    
    if obj.SMenu(iI).GroupIndex ~= 256
        % Icons
        if exist([sIconPath, obj.SMenu(iI).Name, '1.png'], 'file')
            [~, ~, dImg1] = imread([sIconPath, obj.SMenu(iI).Name, '1.png']); % icon file name (.png) has to be equal to icon name
        else
            dImg1 = dImg;
            if obj.SMenu(iI).GroupIndex == 0, dImg  = 0.5.*dImg; end
        end
        dImg = double(cat(3, dImg, dImg1));
        if obj.SMenu(iI).SubGroup, dImg = dImg + dSub; end
        cIcons{iI} = dImg.*dFade./255;
    else
        % Tabs
        dImg = imresize(double(dImg(15:62,15:62))./255, [32 32], 'bicubic');
        dImg = padarray(dImg, (size(dTab) - size(dImg))/2, 0, 'both');
        dImg = fBlend(obj.dBGCOLOR*2, [1 1 1], 'normal', dImg);
        cIcons{iI} = cat(3, dImg, dTab);
    end
    
end


function cIconsScaled = fScaleIcons(obj, cIcons)

cIconsScaled = cell(size(cIcons));
for iI = 1:length(cIcons)
    if obj.SMenu(iI).GroupIndex ~= 256
        cIconsScaled{iI} = imresize(cIcons{iI}, [obj.iIconSize obj.iIconSize], 'bicubic');
        cIconsScaled{iI}(cIconsScaled{iI} < 0) = 0;
        cIconsScaled{iI}(cIconsScaled{iI} > 1) = 1;
    else
        cIconsScaled{iI} = cIcons{iI};
    end
end
