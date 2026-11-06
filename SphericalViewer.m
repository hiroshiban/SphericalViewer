function SphericalViewer(videoType, filepath, renderer)
% SPHERICALVIEWER Explore 360-degree equirectangular images and videos.
%   SphericalViewer opens a file dialog and uses standard MATLAB graphics.
%   SphericalViewer(videoType, filepath, renderer)
%     videoType: 1 = mono (default), 2 = over-under, 3 = side-by-side.
%     filepath: image/video path; [] opens a file dialog.
%     renderer: 'matlab' (default) or 'ptb' (Psychtoolbox-3/OpenGL).
%   Packed stereo inputs show only the top/left eye on a desktop display.
%
%   SphericalViewer(1, 'samples/sample_360deg_VR_image.jpg')
%   SphericalViewer(2, 'samples/sample_360deg_VR_movie.mp4')
%
%   See also SphericalImageViewer, SphericalVideoViewer,
%            SphericalImageViewerPTB, SphericalVideoViewerPTB.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    if nargin < 1, videoType = []; end
    if nargin < 2, filepath = []; end
    if nargin < 3 || isempty(renderer), renderer = 'matlab'; end
    renderer = validatestring(renderer, {'matlab', 'ptb'}, ...
        mfilename, 'renderer');
    [videoType, filepath] = sphericalMediaInput(videoType, filepath, 'all');
    if isempty(filepath), return; end
    [~, ~, extension] = fileparts(filepath);
    isVideo = ismember(lower(extension), {'.mp4', '.mov', '.avi', '.m4v'});
    if strcmp(renderer, 'ptb')
        if isVideo
            SphericalVideoViewerPTB(videoType, filepath);
        else
            SphericalImageViewerPTB(videoType, filepath);
        end
    elseif isVideo
        SphericalVideoViewer(videoType, filepath);
    else
        SphericalImageViewer(videoType, filepath);
    end
end
