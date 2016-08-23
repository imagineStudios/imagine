function viewUp(obj, hObject, ~)

set(hObject, 'WindowButtonMotionFcn', @obj.mouseMove, 'WindowButtonUpFcn', '', 'WindowButtonDownFcn', '');

% -------------------------------------------------------------------------
% If over an axis...
% iSeries = obj.SAction.hView.hData(1);

if ~obj.SAction.lMoved
    
    switch obj.SAction.sSelectionType
        
        case 'normal' % In 3d mode: jump to coordinate
        if strcmp(obj.getTool, 'cursor') && obj.isOn('3d')
            
            iDim = obj.SAction.hView.hData(1).Dims(obj.SAction.iDimInd, :);
            dCoord = obj.SAction.hView.getCurrentPoint(obj.SAction.iDimInd);
            
            for iI = 1:length(obj.hViews)
                obj.hViews(iI).DrawCenter(iDim([2 1])) = dCoord(1, 1:2);
            end
            obj.hViews.position;
            % obj.grid;
            if obj.isOn('3d')
                obj.draw;
            end

        end
        
        case 'alt'
            obj.contextMenu(10);
        
    end
else
    switch obj.getTool
        
        case 'cursor'
            if obj.isOn('3d') || ~strcmp(obj.SAction.sSelectionType, 'normal')
%                 obj.draw;
            end
            
        case 'swap'
            
            iView = obj.getView.iInd;
            iSeries = obj.SView(iView).iData(1);
            iStartSeries = obj.SView(obj.SAction.iView).iData(1);
            
            if iSeries ~= iStartSeries && iSeries
                
                if obj.isOn('3d')
                    iMapping2 = obj.iStartSeries + iView - 1;
                    iMapping1 = obj.iStartSeries + obj.SAction.iView - 1;
                else
                    iMapping2 = obj.iStartSeries + ceil(iView./3) - 1;
                    iMapping1 = obj.iStartSeries + ceil(obj.SAction.iView./3) - 1;
                end
                
                switch get(obj.hF, 'SelectionType')
                    
                    case 'normal'
                            
                        temp = obj.iMapping(iMapping1, :);
                        obj.iMapping(iMapping1, :) = obj.iMapping(iMapping2, :);
                        obj.iMapping(iMapping2, :) = temp;
                        
                    case 'alt'
                        
                        obj.cMapping{iMapping2} = [obj.cMapping{iMapping2}, obj.cMapping{iMapping1}];
                        iInd = 1:length(obj.cMapping);
                        iInd = iInd(iInd ~=iMapping1);
                        obj.cMapping = obj.cMapping(iInd);
                        
                end
                
                obj.setViewMapping;
                
            end
            
            set(obj.SImgs.hUtil, 'Visible', 'off');
            
            obj.position;
            obj.draw;
            obj.grid;
            
        case 'profile'
            
            if isnumeric(obj.SAction.iView)
                if obj.SAction.iView
                    obj.iconDown('stats');
                    obj.drawGraph;
                end
            end
            
            
        case 'roi'
            
            if isnumeric(obj.SAction.iView)
                if obj.SAction.iView
                    
                    dX = unique(get(obj.SView(obj.SAction.iView).hLine(1), 'XData'));
                    dY = unique(get(obj.SView(obj.SAction.iView).hLine(1), 'YData'));
                    
                    iStartDim = obj.SData(obj.SView(obj.SAction.iView).iData).iDims(obj.SView(obj.SAction.iView).iDimInd, :);
                    
                    for iView = 1:numel(obj.SView)
                        SView = obj.SView(iView);
                        if all(iStartDim == obj.SData(SView.iData).iDims(SView.iDimInd, :));
                            
                            [dImg, dXData, dYData] = obj.getData(SView, 0, 0);
                            
                            lXIn = ~(dXData < dX(1) | dXData > dX(end));
                            lYIn = ~(dYData < dY(1) | dYData > dY(end));
                            
                            dImg = dImg(lYIn, lXIn);
                            
                            dDataOut(iView) = max(dImg(:));
                            
                        end
                    end
                    dDataOut = dDataOut(dDataOut ~= 0);
                    assignin('base', 'temp', dDataOut);
                    evalin('base', 'a(end + 1,:) = temp;');
                    
                end
            end
            
            
    end
end

% -------------------------------------------------------------------------












% set(STexts.hStatus, 'String', '');
% % -----------------------------------------------------------------
%
% % -----------------------------------------------------------------
% % Tool-specific code
% switch SState.sTool
%     % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%     % The NORMAL CURSOR: select, move, zoom, window
%     % In this function, only the select case has to be handled
%     case 'cursor_arrow'
%         if ~sum(abs(iCursorPos - SAction.iStartPos)) % Proceed only if mouse was moved
%
%             switch get(hF, 'SelectionType')
%                 % - - - - - - - - - - - - - - - - - - - - - - - - -
%                 % NORMAL selection: Select only current series
%                 case 'normal'
%                     iN = fGetNActiveVisibleSeries();
%                     for iSeries = 1:length(SData)
%                         if SAction.iStartView + SState.iStartSeries - 1 == iSeries
%                             SData(iSeries).lActive = ~SData(iSeries).lActive || iN > 1;
%                         else
%                             SData(iSeries).lActive = false;
%                         end
%                     end
%                     SState.iLastSeries = SAction.iStartView + SState.iStartSeries - 1; % The lastAxis is needed for the shift-click operation
%                     % end of normal selection
%                     % - - - - - - - - - - - - - - - - - - - - - - - - -
%
%                     % - - - - - - - - - - - - - - - - - - - - - - - - -
%                     %  Shift key or right mouse button: Select ALL axes
%                     %  between last selected axis and current axis
%                 case 'extend'
%                     iSeriesInd = SAction.iStartView + SState.iStartSeries - 1;
%                     if sum([SData.lActive] == true) == 0
%                         % If no panel active, only select the current axis
%                         SData(iSeriesInd).lActive = true;
%                         SState.iLastSeries = iSeriesInd;
%                     else
%                         if SState.iLastSeries ~= iSeriesInd
%                             iSortedInd = sort([SState.iLastSeries, iSeriesInd], 'ascend');
%                             for i = 1:length(SData)
%                                 SData(i).lActive = (i >= iSortedInd(1)) && (i <= iSortedInd(2));
%                             end
%                         end
%                     end
%                     % end of shift key/right mouse button
%                     % - - - - - - - - - - - - - - - - - - - - - - - - -
%
%                     % - - - - - - - - - - - - - - - - - - - - - - - - -
%                     % Cntl key or middle mouse button: ADD/REMOVE axis
%                     % from selection
%                 case 'alt'
%                     iSeriesInd = SAction.iStartView + SState.iStartSeries - 1;
%                     SData(iSeriesInd).lActive = ~SData(iSeriesInd).lActive;
%                     SState.iLastSeries = iSeriesInd;
%                     % end of alt/middle mouse buttton
%                     % - - - - - - - - - - - - - - - - - - - - - - - - -
%
%             end
%         end
%         % end of the NORMAL CURSOR
%         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
%         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%         % The LINE EVALUATION tool
% %     case 'line'
% %         fEval(SState.csEvalLineFcns);
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % End of the LINE EVALUATION tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % The ROI EVALUATION tool
% %     case 'roi'
% %         set(hF, 'WindowButtonMotionFcn', @fWindowMouseMoveFcn);
% %         set(hF, 'WindowButtonDownFcn', '');
% %         set(hF, 'WindowButtonUpFcn', @fWindowButtonUpFcn); % But keep the button up function
% %
% %         if iAxisInd && iAxisInd + SState.iStartSeries - 1 <= length(SData) % ROI drawing in progress
% %             dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
% %
% %             if SState.iROIState > 1 || any(strcmp({'extend', 'open'}, get(hF, 'SelectionType')))
% %
% %                 SState.dROILineX = [SState.dROILineX; SState.dROILineX(1)]; % Close line
% %                 SState.dROILineY = [SState.dROILineY; SState.dROILineY(1)];
% %
% %                 delete(SLines.hEval);
% %                 SState.iROIState = 0;
% %                 set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
% %                 set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
% %                 set(hF, 'WindowButtonUpFcn', '');
% %                 fEval(SState.csEvalROIFcns);
% %                 return
% %             end
% %
% %             switch get(hF, 'SelectionType')
% %
% %                 % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %                 % NORMAL selection: Add point to roi
% %                 case 'normal'
% %                     if ~SState.iROIState % This is the first polygon point
% %                         SState.dROILineX = dPos(1, 1);
% %                         SState.dROILineY = dPos(1, 2);
% %                         for i = 1:length(SPanels.hImg)
% %                             if i + SState.iStartSeries - 1 > length(SData), continue, end
% %                             SLines.hEval(i) = line(SState.dROILineX, SState.dROILineY, ...
% %                                 'Parent'    , SAxes.hImg(i), ...
% %                                 'Color'     , SPref.dCOLORMAP(i,:),...
% %                                 'LineStyle' , '-');
% %                         end
% %                         SState.iROIState = 1;
% %                     else % Add point to existing polygone
% %                         SState.dROILineX = [SState.dROILineX; dPos(1, 1)];
% %                         SState.dROILineY = [SState.dROILineY; dPos(1, 2)];
% %                         set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
% %                     end
% %                     % End of NORMAL selection
% %                     % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %                     % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %                     % Right mouse button/shift key: UNDO last point, quit
% %                     % if is no point remains
% %                 case 'alt'
% %                     if ~SState.iROIState, return, end    % Only perform action if painting in progress
% %
% %                     if length(SState.dROILineX) > 1
% %                         SState.dROILineX = SState.dROILineX(1:end-1); % Delete last point
% %                         SState.dROILineY = SState.dROILineY(1:end-1);
% %                         dROILineX = [SState.dROILineX; dPos(1, 1)]; % But draw line to current cursor position
% %                         dROILineY = [SState.dROILineY; dPos(1, 2)];
% %                         set(SLines.hEval, 'XData', dROILineX, 'YData', dROILineY);
% %                     else % Abort drawing ROI
% %                         SState.iROIState = 0;
% %                         delete(SLines.hEval);
% %                         SLines = rmfield(SLines, 'hEval');
% %                         set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
% %                         set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn); % Disable the button down function
% %                     end
% %                     % End of right click/shift-click
% %                     % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %             end
% %         end
% %         % End of the ROI EVALUATION tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % The LIVEWIRE EVALUATION tool
% %     case 'lw'
% %         set(hF, 'WindowButtonMotionFcn', @fWindowMouseMoveFcn);
% %         set(hF, 'WindowButtonDownFcn', '');
% %         set(hF, 'WindowButtonUpFcn', @fWindowButtonUpFcn); % But keep the button up function
% %         if iAxisInd ~= SAction.iStartView, return, end
% %
% %         dPos = get(SAxes.hImg(SAction.iStartView), 'CurrentPoint');
% %         switch get(hF, 'SelectionType')
% %
% %             % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %             % NORMAL selection: Add point to roi
% %             case 'normal'
% %                 if ~SState.iROIState % This is the first polygon point
% %                     dImg = SData(SAction.iStartView + SState.iStartSeries - 1).dImg(:,:,SData(SAction.iStartView + SState.iStartSeries - 1).iCenterPoint(3));
% %                     SState.dLWCostFcn = fLiveWireGetCostFcn(dImg);
% %                     SState.dROILineX = dPos(1, 1);
% %                     SState.dROILineY = dPos(1, 2);
% %                     for i = 1:length(SPanels.hImg)
% %                         if i + SState.iStartSeries - 1 > length(SData), continue, end
% %                         SLines.hEval(i) = line(SState.dROILineX, SState.dROILineY, ...
% %                             'Parent'    , SAxes.hImg(i), ...
% %                             'Color'     , SPref.dCOLORMAP(i,:),...
% %                             'LineStyle' , '-');
% %                     end
% %                     SState.iROIState = 1;
% %                     SState.iLWAnchorList = zeros(200, 1);
% %                     SState.iLWAnchorInd  = 0;
% %                 else % Add point to existing polygone
% %                     [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, dPos(1, 1), dPos(1, 2));
% %                     if isempty(iXPath)
% %                         iXPath = dPos(1, 1);
% %                         iYPath = dPos(1, 2);
% %                     end
% %                     SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
% %                     SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
% %                     set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
% %                 end
% %                 SState.iLWAnchorInd = SState.iLWAnchorInd + 1;
% %                 SState.iLWAnchorList(SState.iLWAnchorInd) = length(SState.dROILineX); % Save the previous path length for the undo operation
% %                 [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, dPos(1, 1), dPos(1, 2), SPref.dLWRADIUS);
% %                 % End of NORMAL selection
% %                 % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %                 % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %                 % Right mouse button/shift key: UNDO last point, quit
% %                 % if is no point remains
% %             case 'alt'
% %                 if SState.iROIState
% %                     SState.iLWAnchorInd = SState.iLWAnchorInd - 1;
% %                     if SState.iLWAnchorInd
% %                         SState.dROILineX = SState.dROILineX(1:SState.iLWAnchorList(SState.iLWAnchorInd)); % Delete last point
% %                         SState.dROILineY = SState.dROILineY(1:SState.iLWAnchorList(SState.iLWAnchorInd));
% %                         set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
% %                         drawnow;
% %                         [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, SState.dROILineX(end), SState.dROILineY(end), SPref.dLWRADIUS);
% %                         fWindowMouseMoveFcn(hObject, []);
% %                     else % Abort drawing ROI
% %                         SState.iROIState = 0;
% %                         delete(SLines.hEval);
% %                         SLines = rmfield(SLines, 'hEval');
% %                         set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
% %                         set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
% %                     end
% %                 end
% %                 % End of right click/shift-click
% %                 % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %                 % Middle mouse button/double-click/cntl-click: CLOSE
% %                 % POLYGONE and quit roi action
% %             case {'extend', 'open'} % Middle mouse button or double-click ->
% %                 if ~SState.iROIState, return, end    % Only perform action if painting in progress
% %
% %                 [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, dPos(1, 1), dPos(1, 2));
% %                 if isempty(iXPath)
% %                     iXPath = dPos(1, 1);
% %                     iYPath = dPos(1, 2);
% %                 end
% %                 SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
% %                 SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
% %
% %                 [SState.iPX, SState.iPY] = fLiveWireCalcP(SState.dLWCostFcn, dPos(1, 1), dPos(1, 2), SPref.dLWRADIUS);
% %                 [iXPath, iYPath] = fLiveWireGetPath(SState.iPX, SState.iPY, SState.dROILineX(1), SState.dROILineY(1));
% %                 if isempty(iXPath)
% %                     iXPath = SState.dROILineX(1);
% %                     iYPath = SState.dROILineX(2);
% %                 end
% %                 SState.dROILineX = [SState.dROILineX; double(iXPath(:))];
% %                 SState.dROILineY = [SState.dROILineY; double(iYPath(:))];
% %                 set(SLines.hEval, 'XData', SState.dROILineX, 'YData', SState.dROILineY);
% %
% %                 delete(SLines.hEval);
% %                 SState.iROIState = 0;
% %                 set(hF, 'WindowButtonMotionFcn',@fWindowMouseHoverFcn);
% %                 set(hF, 'WindowButtonDownFcn', @fWindowButtonDownFcn);
% %                 set(hF, 'WindowButtonUpFcn', '');
% %                 fEval(SState.csEvalROIFcns);
% %
% %                 % End of middle mouse button/double-click/cntl-click
% %                 % - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %         end
% %         % End of the LIVEWIRE EVALUATION tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % The REGION GROWING tool
% %     case 'rg'
% %         if ~strcmp(get(hF, 'SelectionType'), 'normal'), return, end; % Otherwise calling the context menu starts a rg
% %         if ~iAxisInd || iAxisInd > length(SData), return, end;
% %
% %         iSeriesInd = iAxisInd + SState.iStartSeries - 1;
% %         iSize = size(SData(iSeriesInd).dImg);
% %         dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
% %         if dPos(1, 1) < 1 || dPos(1, 2) < 1 || dPos(1, 1) > iSize(2) || dPos(1, 2) > iSize(1), return, end
% %
% %         fEval(SState.csEvalVolFcns);
% %         % End of the REGION GROWING tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % The ISOCONTOUR tool
% %     case 'ic'
% %         if ~iAxisInd || iAxisInd > length(SData), return, end;
% %
% %         iSeriesInd = iAxisInd + SState.iStartSeries - 1;
% %         iSize = size(SData(iSeriesInd).dImg);
% %         dPos = get(SAxes.hImg(iAxisInd), 'CurrentPoint');
% %         if dPos(1, 1) < 1 || dPos(1, 2) < 1 || dPos(1, 1) > iSize(2) || dPos(1, 2) > iSize(1), return, end
% %
% %         fEval(SState.csEvalVolFcns);
% %         % End of the ISOCONTOUR tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% %
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %         % The PROPERTIES tool: Rename the data
% %     case 'tag'
% %         if ~iAxisInd || iAxisInd > length(SData), return, end;
% %
% %         iSeriesInd = SState.iStartSeries + iAxisInd - 1;
% %         csPrompt = {'Name', 'Voxel Size', 'Units'};
% %         dDim = SData(iSeriesInd).dPixelSpacing;
% %         sDim = sprintf('%4.2f x ', dDim([2, 1, 3]));
% %         csVal = {SData(iSeriesInd).sName, sDim(1:end-3), SData(iSeriesInd).sUnits};
% %         csAns    = inputdlg(csPrompt, sprintf('Change %s', SData(iSeriesInd).sName), 1, csVal);
% %         if isempty(csAns), return, end
% %
% %         sName = csAns{1};
% %         iInd = find([SData.iGroupIndex] == SData(iSeriesInd).iGroupIndex);
% %         if length(iInd) > 1
% %             if ~isnan(str2double(sName(end - 1:end))), sName = sName(1:end - 2); end % Crop the number
% %         end
% %         dDim = cell2mat(textscan(csAns{2}, '%fx%fx%f'));
% %         iCnt = 1;
% %         for i = iInd
% %             if length(iInd) > 1
% %                 SData(i).sName = sprintf('%s%02d', sName, iCnt);
% %             else
% %                 SData(i).sName = sName;
% %             end
% %             SData(i).dPixelSpacing  = dDim([2, 1, 3]);
% %             SData(i).sUnits = csAns{3};
% %             iCnt = iCnt + 1;
% %         end
% %         fFillPanels;
% %         % End of the TAG tool
% %         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% %
% end
% % end of the tool switch-statement
% % -----------------------------------------------------------------
%
% % fUpdateActivation();