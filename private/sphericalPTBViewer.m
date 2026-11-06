function sphericalPTBViewer(videoType, filepath, isVideo)
% Shared PTB preview loop. Screen sync preferences are left to the caller.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    if isempty(which('Screen'))
        error('SphericalViewer:PsychtoolboxRequired', ...
            'Install Psychtoolbox-3 to use the ptb renderer.');
    end
    AssertOpenGL;
    InitializeMatlabOpenGL;
    KbName('UnifyKeyNames');
    if ~isVideo
        imageData = sphericalCropMedia(imread(filepath), videoType);
    end
    screenId = max(Screen('Screens'));
    [win, ~] = Screen('OpenWindow', screenId, 0);
    windowCleanup = onCleanup(@() closeWindow(win));
    [width, height] = Screen('WindowSize', win);
    texture = [];
    if isVideo
        [movie, ~, ~, mediaWidth, mediaHeight] = Screen('OpenMovie', win, filepath);
        movieCleanup = onCleanup(@() closeMovie(movie));
        if (videoType == 2 && mod(mediaHeight, 2) ~= 0) || ...
                (videoType == 3 && mod(mediaWidth, 2) ~= 0)
            error('SphericalViewer:OddStereoSize', ...
                'Packed stereo dimensions must divide into two equal eyes.');
        end
    else
        texture = Screen('MakeTexture', win, imageData);
        textureCleanup = onCleanup(@() closeTexture(texture));
    end
    quadric = makeQuadric(win);
    quadricCleanup = onCleanup(@() gluDeleteQuadric(quadric));
    % Raw valuators are optional; keyboard zoom is always available.
    wheelEnabled = true; mouseDevice = [];
    if IsWin
        try
            devices = GetMouseIndices;
            if isempty(devices), error('SphericalViewer:NoMouse', 'No mouse found.'); end
            mouseDevice = devices(1);
            KbQueueCreate(mouseDevice, [], 3, [], 4);
            queueCleanup = onCleanup(@() releaseQueue(mouseDevice));
            KbQueueStart(mouseDevice);
        catch err
            wheelEnabled = false;
            warning('SphericalViewer:MouseWheelUnavailable', ...
                'Mouse wheel unavailable (%s). Use + and - to zoom.', err.message);
        end
    end
    escapeKey = KbName('ESCAPE');
    zoomInKeys = [KbName('=+'), KbName('UpArrow')];
    zoomOutKeys = [KbName('-_'), KbName('DownArrow')];
    yaw = 0; pitch = 0; fov = 60;
    dragging = false; lastPosition = [0 0]; lastZoom = -Inf;
    if isVideo, Screen('PlayMovie', movie, 1, 0, 1); end
    while true
        [keyDown, now, keyCode] = KbCheck;
        if keyDown && keyCode(escapeKey), break; end
        if keyDown && now - lastZoom >= 0.1
            if any(keyCode(zoomInKeys))
                fov = max(5, fov - 3); lastZoom = now;
            elseif any(keyCode(zoomOutKeys))
                fov = min(140, fov + 3); lastZoom = now;
            end
        end
        [mx, my, buttons] = GetMouse(win);
        pressed = ~isempty(buttons) && buttons(1);
        if pressed && dragging
            delta = [mx my] - lastPosition;
            yaw = yaw - delta(1) * 0.3;
            pitch = max(-89, min(89, pitch - delta(2) * 0.3));
        end
        dragging = pressed; lastPosition = [mx my];
        wheel = 0;
        if wheelEnabled
            try
                if IsWin
                    while KbEventAvail(mouseDevice)
                        event = KbEventGet(mouseDevice);
                        if isstruct(event) && isfield(event, 'Valuators') && ...
                                numel(event.Valuators) >= 3
                            wheel = wheel + event.Valuators(3);
                        end
                    end
                else
                    wheel = GetMouseWheel;
                end
            catch
                wheelEnabled = false;
                warning('SphericalViewer:MouseWheelUnavailable', ...
                    'Mouse wheel unavailable. Use + and - to zoom.');
            end
        end
        fov = max(5, min(140, fov - sign(wheel) * 3));
        if isVideo
            % Nonblocking fetch keeps Escape and navigation responsive.
            nextTexture = Screen('GetMovieImage', win, movie, 0);
            if nextTexture < 0, break; end
            if nextTexture > 0
                clear textureCleanup;
                texture = nextTexture;
                textureCleanup = onCleanup(@() closeTexture(texture));
            end
        end
        if isempty(texture), WaitSecs('YieldSecs', 0.001); continue; end
        drawSphere(win, texture, quadric, videoType, isVideo, width/height, yaw, pitch, fov);
        Screen('Flip', win);
    end
end

function quadric = makeQuadric(win)
    Screen('BeginOpenGL', win);
    glCleanup = onCleanup(@() endOpenGL(win));
    quadric = gluNewQuadric;
end

function drawSphere(win, texture, quadric, videoType, isVideo, aspect, yaw, pitch, fov)
    global GL; %#ok<GVMIS>
    [texWidth, texHeight] = Screen('WindowSize', texture);
    xEnd = texWidth; yEnd = texHeight;
    if isVideo && videoType == 2, yEnd = texHeight / 2; end
    if isVideo && videoType == 3, xEnd = texWidth / 2; end
    % Convert three pixel corners using PTB, including texture orientation.
    [glTexture, target, u0, v0] = Screen('GetOpenGLTexture', win, texture, 0, 0);
    [~, ~, u1, v1] = Screen('GetOpenGLTexture', win, texture, xEnd, 0);
    [~, ~, u2, v2] = Screen('GetOpenGLTexture', win, texture, 0, yEnd);
    % GLU's t=1 is the north pole, which maps to the image's top row.
    textureMatrix = [u1-u0, u0-u2, 0, u2; ...
                     v1-v0, v0-v2, 0, v2; ...
                     0, 0, 1, 0; 0, 0, 0, 1];
    Screen('BeginOpenGL', win);
    glCleanup = onCleanup(@() endOpenGL(win));
    glClear(GL.COLOR_BUFFER_BIT + GL.DEPTH_BUFFER_BIT);
    glDisable(GL.CULL_FACE); glDisable(GL.LIGHTING);
    glMatrixMode(GL.PROJECTION); glLoadIdentity;
    gluPerspective(fov, aspect, 0.1, 1000);
    glMatrixMode(GL.MODELVIEW); glLoadIdentity;
    direction = [cosd(pitch)*sind(yaw), -cosd(pitch)*cosd(yaw), sind(pitch)];
    gluLookAt(0, 0, 0, direction(1), direction(2), direction(3), 0, 0, 1);
    glEnable(target); glBindTexture(target, glTexture);
    glMatrixMode(GL.TEXTURE); glLoadMatrixd(textureMatrix);
    glMatrixMode(GL.MODELVIEW);
    glColor3f(1, 1, 1);
    gluQuadricTexture(quadric, GL.TRUE);
    gluSphere(quadric, 100, 100, 100);
    glDisable(target);
    glMatrixMode(GL.TEXTURE); glLoadIdentity;
    glMatrixMode(GL.MODELVIEW);
end

function endOpenGL(win)
    try Screen('EndOpenGL', win); catch, end
end

function closeWindow(win)
    try Screen('Close', win); catch, end
end

function closeTexture(texture)
    try Screen('Close', texture); catch, end
end

function closeMovie(movie)
    try Screen('PlayMovie', movie, 0); catch, end
    try Screen('CloseMovie', movie); catch, end
end

function releaseQueue(device)
    try KbQueueStop(device); catch, end
    try KbQueueRelease(device); catch, end
end
