function SphericalImageViewerPTB(videoType, imagefile)
% SPHERICALIMAGEVIEWERPTB Fullscreen 360-degree image preview with PTB3.
%   SphericalImageViewerPTB(videoType, imagefile)
%   videoType: 1=mono (default), 2=over-under (top), 3=side-by-side (left).
%   Omit imagefile or pass [] to select an image with a file dialog.
%   Drag the left mouse button to look around; wheel or +/- to zoom;
%   Escape to exit. This is a single-eye desktop preview, not HMD output.
%   See also SphericalViewer, SphericalImageViewer.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    if nargin < 1, videoType = []; end
    if nargin < 2, imagefile = []; end
    [videoType, imagefile] = sphericalMediaInput(videoType, imagefile, 'image');
    if isempty(imagefile), return; end
    sphericalPTBViewer(videoType, imagefile, false);
end
