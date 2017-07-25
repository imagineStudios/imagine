%IMAGINE IMAGe visualization and evaluation engINE
%
%   IMAGINE starts the IMAGINE user interface without initial data
%
%   IMAGINE(DATA) Starts the IMAGINE user interface with one (DATA is 3D)
%   or multiple panels (DATA is 4D).
%
%   IMAGINE(DATA, PROPERTY1, VALUE1, ...)) Starts the IMAGINE user
%   interface with data DATA plus supplying some additional information
%   about the dataset in the usual property/value pair format. Possible
%   combinations are:
%
%       PROPERTY        VALUE
%       -------------------------------------------------------------------
%       'Name'          String: A name for the dataset
%       'Resolution'    [3x1] or [1x3] double: The voxel size of the first
%                       three dimensions of DATA.
%       'Units'         String: The physical unit of the pixels (e.g. 'mm')
%       'Zoom'          Initial zoom level for DATA (scalar)
%       'Window'        [1x2] double vector indicating the initial lower
%                       and upper intensity values used for the scaling of 
%                       intensity.
%
%   IMAGINE(DATA1, DATA2, ...) Starts the IMAGINE user interface with
%   multiple panels, where each input can be either a 3D- or 4D-array. Each
%   dataset can be defined more detailedly with the properties above. 
%
%
% Examples:
%
% 1. >> load mri % Gives variable D
%    >> imagine(squeeze(D)); % squeeze because D is in rgb format
%
% 2. >> load mri % Gives variable D
%    >> imagine(squeeze(D), 'Name', 'Head T1', 'Resolution', [2.2 2.2 2.2*2.7], 'Orient', 'tra');
% This syntax gives a more realistic aspect ration if you rotate the data.
%
% For more information about the IMAGINE functions refer to the user's
% guide file in the documentation folder supplied with the code.
%
% Copyright 2016 Christian Wuerslin
% Contact: c.wuerslin@gmail.com
function hObj = imagine(varargin)

hObj = CImagine(varargin{:});