function SphericalImageViewer(videoType, imagefile)
% =========================================================================
% SPHERICALIMAGEVIEWER
% A lightweight 360-degree image viewer using standard MATLAB graphics.
%
% USAGE:
%   SphericalImageViewer(videoType, imagefile)
%   - videoType: 1=Mono, 2=Over-Under (top eye), 3=Side-by-Side (left eye)
%   - imagefile: Path to image. If empty, a file dialog will open.
%   Packed stereo sources are previewed as a single eye on a desktop display.
%
% CONTROLS:
%   - Mouse Drag: Rotate view (Yaw/Pitch)
%   - Mouse Wheel: Zoom In/Out (Field of View)
%   - ESC: Close the program
% =========================================================================
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).

    % --- 1. Initialization and Image Loading ---
    if nargin < 1, videoType = []; end
    if nargin < 2, imagefile = []; end
    [videoType, imagefile] = sphericalMediaInput(videoType, imagefile, 'image');
    if isempty(imagefile), return; end

    imgRaw = imread(imagefile);
    img = sphericalCropMedia(imgRaw, videoType);

    % --- 2. Setup Graphics Environment ---
    fig = figure('Name', ['Spherical Image: ' imagefile], ...
        'NumberTitle', 'off', 'Color', 'k', 'MenuBar', 'none', 'Units', 'pixels');

    ax = axes('Parent', fig, 'Position', [0 0 1 1], 'Visible', 'off', ...
        'SortMethod', 'childorder');
    hold(ax, 'on');

    % Create sphere and flip Z-axis (-z) to map texture to the interior
    [x, y, z] = sphere(100);
    surface(ax, -y, -x, -z, 'FaceColor', 'texturemap', 'CData', img, 'EdgeColor', 'none');

    % Camera configuration for immersive interior view
    set(ax, 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatio', [1 1 1]);
    camproj(ax, 'perspective');
    set(ax, 'CameraPosition', [0 0 0], 'CameraViewAngle', 60, ...
        'CameraUpVector', [0 0 1]);

    % Store state variables in appdata for persistence across callbacks
    setappdata(fig, 'yaw', 0);
    setappdata(fig, 'pitch', 0);
    setappdata(fig, 'isDragging', false);
    setappdata(fig, 'lastMousePos', [0 0]);

    % Initialize default orientation
    updateStandardView(ax, 0, 0);

    % Register interaction callbacks
    set(fig, 'WindowButtonDownFcn', @mouseDown);
    set(fig, 'WindowButtonMotionFcn', @mouseMove);
    set(fig, 'WindowButtonUpFcn', @mouseUp);
    set(fig, 'WindowScrollWheelFcn', @mouseZoom);
    set(fig, 'WindowKeyPressFcn', @keyPress);

    % --- Internal Helper Functions ---

    function updateStandardView(a, y, p)
        % Map Yaw/Pitch angles to a 3D target vector
        target = [cosd(p)*sind(y), -cosd(p)*cosd(y), sind(p)];
        set(a, 'CameraTarget', target);
    end

    function mouseDown(src, ~)
        % Capture starting mouse position for dragging
        setappdata(src, 'lastMousePos', get(0, 'PointerLocation'));
        setappdata(src, 'isDragging', true);
    end

    function mouseMove(src, ~)
        if ~getappdata(src, 'isDragging'), return; end

        % Retrieve stored angles and mouse delta
        yaw = getappdata(src, 'yaw');
        pitch = getappdata(src, 'pitch');
        lastPos = getappdata(src, 'lastMousePos');
        currPos = get(0, 'PointerLocation');

        diff = currPos - lastPos;
        gain = 1.0; % Rotation sensitivity factor

        % Calculate new angles with pitch clamping to avoid "gimbal lock" flip
        newYaw = yaw - diff(1) * gain;
        newPitch = max(-89, min(89, pitch + diff(2) * gain));

        % Apply visual update
        updateStandardView(ax, newYaw, newPitch);

        % Update persistent state
        setappdata(src, 'yaw', newYaw);
        setappdata(src, 'pitch', newPitch);
        setappdata(src, 'lastMousePos', currPos);
        drawnow limitrate;
    end

    function mouseUp(src, ~)
        setappdata(src, 'isDragging', false);
    end

    function mouseZoom(~, evnt)
        % Adjust Field of View (FOV) based on scroll wheel delta
        newAngle = max(5, min(140, get(ax, 'CameraViewAngle') + evnt.VerticalScrollCount * 3));
        set(ax, 'CameraViewAngle', newAngle);
    end

    function keyPress(src, event)
        if strcmp(event.Key, 'escape'), delete(src); end
    end
end
