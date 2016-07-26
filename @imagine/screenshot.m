function iImg = screenshot(obj)

% -------------------------------------------------------------------------
% Make sure that all the overlays are hidden before capturing and figure is
% up to date
% obj.tooltip('');
obj.contextMenu(0);
drawnow;
pause(0.1);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Get all kinds of graphic element positions
dScreenSize = get(0,'ScreenSize');

dFigureOuterPos = get(obj.hF, 'OuterPosition');
dFiguerInnerPos = get(obj.hF, 'Position');

dMenuSize = get(obj.SAxes.hMenu, 'Position');
dToolSize = get(obj.SAxes.hTools, 'Position');
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Define the target region in MATLAB ...
dCaptureRect = [dToolSize(3) + 1, 1, ...
                dFiguerInnerPos(3) - dToolSize(3) - 2 - obj.iSidebarWidth, ...
                dFiguerInnerPos(4) - dMenuSize(4) - 2];

% ... and JAVA coordinates           
dXStart  = dFigureOuterPos(1) + dCaptureRect(1) - 1;
dYStart  = dScreenSize(4) - dFigureOuterPos(2) - dCaptureRect(2) - dCaptureRect(4) + 1;
jRect = java.awt.Rectangle(dXStart, dYStart, dCaptureRect(3), dCaptureRect(4));
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Capture and reformat for MATLAB usage
jRobot = java.awt.Robot;
jImage = jRobot.createScreenCapture(jRect);

iH = jImage.getHeight;
iW = jImage.getWidth;
iImg = reshape(typecast(jImage.getData.getDataStorage, 'uint8'), 4, iW, iH);
iImg = permute(flip(iImg(1:3, :, :)), [3 2 1]);
% -------------------------------------------------------------------------
