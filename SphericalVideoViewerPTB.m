function SphericalVideoViewerPTB(videoType, moviefile)
% SPHERICALVIDEOVIEWERPTB Fullscreen 360-degree video preview with PTB3.
%   SphericalVideoViewerPTB(videoType, moviefile)
%   videoType: 1=mono (default), 2=over-under (top), 3=side-by-side (left).
%   Omit moviefile or pass [] to select a video with a file dialog.
%   Drag the left mouse button to look around; wheel or +/- to zoom;
%   Escape to exit. Playback ends automatically at the end of the video.
%   Audio is enabled. Packed stereo sources are previewed as one eye.
%   See also SphericalViewer, SphericalVideoViewer.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    if nargin < 1, videoType = []; end
    if nargin < 2, moviefile = []; end
    [videoType, moviefile] = sphericalMediaInput(videoType, moviefile, 'video');
    if isempty(moviefile), return; end
    sphericalPTBViewer(videoType, moviefile, true);
end
