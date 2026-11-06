function SphericalVideoViewer(videoType, moviefile)
% =========================================================================
% SPHERICALVIDEOVIEWER
% 360-degree video player using standard MATLAB axes and VideoReader.
%
% USAGE:
%   SphericalVideoViewer(videoType, moviefile)
%   - videoType: 1=Mono, 2=Over-Under (top eye), 3=Side-by-Side (left eye)
%   - moviefile: Path to video. If empty, a file dialog will open.
%   Packed stereo sources are previewed as a single eye. Audio is not played.
%
% CONTROLS:
%   - Mouse Drag: Rotate view (Yaw/Pitch)
%   - Mouse Wheel: Zoom In/Out (Field of View)
%   - ESC: Close the program
% =========================================================================
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).

    % --- 1. Load Video Metadata ---
    if nargin < 1, videoType = []; end
    if nargin < 2, moviefile = []; end
    [videoType, moviefile] = sphericalMediaInput(videoType, moviefile, 'video');
    if isempty(moviefile), return; end

    v = VideoReader(moviefile);

    % Setup GUI with custom close behavior to stop playback loop
    fig = figure('Name', ['Spherical Video: ' moviefile], ...
        'NumberTitle', 'off', 'Color', 'k', 'MenuBar', 'none', ...
        'CloseRequestFcn', @closeViewer, ...
        'Units', 'pixels');

    ax = axes('Parent', fig, 'Position', [0 0 1 1], 'Visible', 'off', ...
        'SortMethod', 'childorder');

    % Prepare first frame and sphere mesh
    imgFull = readFrame(v);
    img = sphericalCropMedia(imgFull, videoType);
    [x, y, z] = sphere(100);
    s = surface(ax, -y, -x, -z, 'FaceColor', 'texturemap', 'CData', img, 'EdgeColor', 'none');

    % Viewport configuration
    axis(ax, 'equal'); camproj(ax, 'perspective');
    set(ax, 'CameraPosition', [0 0 0], 'CameraViewAngle', 60, ...
        'CameraUpVector', [0 0 1]);

    % Interaction states
    yaw = 0; pitch = 0; lastPos = [0 0]; isDragging = false;
    updateStandardView(ax, yaw, pitch);
    setappdata(fig, 'running', true);

    % Callbacks for interactive navigation
    set(fig, 'WindowButtonDownFcn', @mouseDown);
    set(fig, 'WindowButtonMotionFcn', @mouseMove);
    set(fig, 'WindowButtonUpFcn', @mouseUp);
    set(fig, 'WindowScrollWheelFcn', @mouseZoom);
    set(fig, 'WindowKeyPressFcn', @keyPress);

    % --- 2. Main Playback Loop ---
    playbackStart = tic;
    frameNumber = 0;
    while isgraphics(fig) && getappdata(fig, 'running')
        % Update texture data for the current frame
        set(s, 'CData', img);
        drawnow;

        % Maintain original framerate
        frameNumber = frameNumber + 1;
        pauseTime = frameNumber/v.FrameRate - toc(playbackStart);
        if pauseTime > 0, pause(pauseTime); end
        if ~isgraphics(fig) || ~hasFrame(v), break; end
        img = sphericalCropMedia(readFrame(v), videoType);
    end

    % --- Internal Helper Functions ---

    function updateStandardView(a, y, p)
        target = [cosd(p)*sind(y), -cosd(p)*cosd(y), sind(p)];
        set(a, 'CameraTarget', target);
    end

    function mouseDown(~, ~)
        lastPos = get(0, 'PointerLocation'); isDragging = true;
    end

    function mouseMove(~, ~)
        if ~isDragging, return; end
        currPos = get(0, 'PointerLocation');
        diff = currPos - lastPos;
        % Direct angular update from pixel delta
        yaw = yaw - diff(1) * 1.0;
        pitch = max(-89, min(89, pitch + diff(2) * 1.0));
        updateStandardView(ax, yaw, pitch);
        lastPos = currPos;
        drawnow limitrate;
    end

    function mouseUp(~, ~)
        isDragging = false;
    end

    function mouseZoom(~, evnt)
        set(ax, 'CameraViewAngle', max(5, min(140, get(ax, 'CameraViewAngle') + evnt.VerticalScrollCount * 3)));
    end

    function keyPress(src, event)
        if strcmp(event.Key, 'escape'), closeViewer(src, []); end
    end

    function closeViewer(src, ~)
        setappdata(src, 'running', false);
        delete(src);
    end
end
