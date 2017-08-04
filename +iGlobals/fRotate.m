function dImgRotated = fRotate(dImg, dAngle, dOrigin)

if nargin < 3, dOrigin = round(size(dImg(:,:,1))./2); end
if nargin < 2, dAngle = 90; end
if nargin < 1
  error('Gotta rotat somethin'', dawg!');
end

if ndims(dImg) < 2 || ndims(dImg) > 3
  error('Input image must be either 2D or 3D!');
end

dAngle = dAngle./180.*pi;
dRotation = [cos(dAngle), - sin(dAngle)
             sin(dAngle),   cos(dAngle)];

[dX, dY] = meshgrid(1:size(dImg, 2), 1:size(dImg, 1));

dCoordOut = dRotation*[dX(:) - dOrigin(1), dY(:) - dOrigin(2)]';

dXR = reshape(dCoordOut(1, :), size(dX)) + dOrigin(1);
dYR = reshape(dCoordOut(2, :), size(dY)) + dOrigin(2);

dImgRotated = zeros(size(dImg));
dImg = double(dImg);
for iI = 1:size(dImg, 3)
  dImgRotated = interp2(dX, dY, dImg(:,:,iI), dXR, dYR, 'bicubic', 0);
end

