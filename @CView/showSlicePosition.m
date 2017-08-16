function showSlicePosition(obj)

dDIST = 6;
sMARKER = 's';

l3D = obj(1).hParent.get3DMode();

for iI = 1:numel(obj)
   
   hView = obj(iI);
   
   if ~isempty(hView.hData)
      
      for iAxesInd = 1:length(hView.hA)
         
         hA = hView.hA(iAxesInd);
         
         if l3D
            dA = hView.dA(:,:,iAxesInd);
         else
            switch(hView.hData(1).Orientation)
               case 'cor', dA = hView.dA(:,:,1);
               case 'sag', dA = hView.dA(:,:,2);
               case 'tra', dA = hView.dA(:,:,3);
               case 'nat', dA = hView.dA(:,:,3);
            end
         end
         
         iDimPermutation = abs(dA'*hView.hData(1).getPermutation());
         
         iSize = abs(dA'*hView.hData(1).getSize());
         iN = iSize(3);
         
         dPos  = get(hA, 'Position');
         dYLim_mm = get(hA, 'YLim');
         dXLim_mm = get(hA, 'XLim');
         dYSize_px = dPos(4);
         dXSize_px = dPos(3);
         
         iNRows = min(floor(dYSize_px.*0.9./dDIST), iN);
         [iNRows, iNCols] = iGlobals.fOptiRows(iN, iNRows);
         
         dYData = dDIST.*( (0:iNRows - 1)' - (iNRows - 1)/2 );
         if strcmp(get(hA, 'YDir'), 'normal')
            dYData = - dYData;
         end
         
         dYData = mean(dYLim_mm) + dYData.*diff(dYLim_mm)./dYSize_px;
         if ~mod(dYSize_px, 2), dYData = dYData + diff(dYLim_mm)./dYSize_px./2; end
         
         dXData = dDIST.*(iNCols + 1:-1:2) + 0.5;
         if strcmp(get(hA, 'XDir'), 'normal')
            dXData = dXLim_mm(2) - dXData.*diff(dXLim_mm)./dXSize_px;
         else
            dXData = dXLim_mm(1) + dXData.*diff(dXLim_mm)./dXSize_px;
         end
         [dY, dX] = ndgrid(dYData, dXData);
         
         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         % Translate to slice indices, determine timepoint
         iInd = hView.hData(1).getSliceLim(hView.DrawCenter, iDimPermutation(3));
         
         dY = dY(1:iN);
         dX = dX(1:iN);
         
         iCol = hView.iRandColor(:,1:iN);
         iCol(:, iInd) = repmat(uint8([1; 1; 1; 0.8].*255), [1 length(iInd)]);
         
         set(hView.hS2(iAxesInd), 'XData', dX, 'YData', dY, 'Visible', 'on', 'SizeData', (dDIST + 1)^2, 'Marker', sMARKER, 'MarkerEdgeColor', 'none');
         try
            h = hView.hS2(iAxesInd).MarkerHandle;
            set(h, 'FaceColorBinding', 'interpolated', 'FaceColorData', iCol);
         catch
            
         end
      end
   end
end

% stop(obj(1).hParent.STimers.hToolTip);
% start(obj(1).hParent.STimers.hToolTip);