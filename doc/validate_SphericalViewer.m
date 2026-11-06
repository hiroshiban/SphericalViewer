function validate_SphericalViewer
% VALIDATE_SPHERICALVIEWER Exercise desktop preview behavior and sample input.
% Run from MATLAB: addpath('doc'); validate_SphericalViewer
% Opens hidden MATLAB figures; does not open a PTB fullscreen window.
% Outputs and generated fixtures are written to .runtime/ (excluded from Git).
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    output = fullfile(root, '.runtime');
    if ~isfolder(output), mkdir(output); end
    oldVisible = get(groot, 'DefaultFigureVisible');
    set(groot, 'DefaultFigureVisible', 'off');
    originals = findall(groot, 'Type', 'figure');
    cleanup = onCleanup(@() restoreState(oldVisible, originals));
    imagefile = fullfile(root, 'samples', 'sample_360deg_VR_image.jpg');
    moviefile = fullfile(root, 'samples', 'sample_360deg_VR_movie.mp4');

    % Validate all public and internal function files with MATLAB's analyzer.
    source = [dir(fullfile(root, '*.m')); dir(fullfile(root, 'private', '*.m'))];
    for k = 1:numel(source)
        messages = checkcode(fullfile(source(k).folder, source(k).name), '-id');
        assert(isempty(messages), 'Code analyzer reported an issue in %s.', source(k).name);
    end
    fprintf('PASS: MATLAB code analyzer (%d files)\n', numel(source));

    % Invalid input fails before a display is opened, including PTB wrappers.
    mustFail(@() SphericalViewer(0, imagefile));
    mustFail(@() SphericalViewer(NaN, imagefile));
    mustFail(@() SphericalViewer(2.5, imagefile));
    mustFail(@() SphericalViewer(1, imagefile, 'invalid'));
    mustFail(@() SphericalImageViewer(1, fullfile(output, 'missing.jpg')));
    mustFail(@() SphericalImageViewerPTB(1, fullfile(output, 'missing.jpg')));
    mustFail(@() SphericalVideoViewerPTB(4, moviefile));
    fprintf('PASS: input validation before graphics/PTB initialization\n');

    raw = imread(imagefile);
    assert(isequal(size(raw), [2880 5760 3]));
    SphericalViewer([], string(imagefile));
    fig = gcf; surf = findobj(fig, 'Type', 'surface');
    assert(isequal(get(surf, 'CData'), raw));
    set(fig, 'Position', [100 100 1000 600]);
    drawnow;
    print(fig, fullfile(output, 'sample_view.jpg'), '-djpeg', '-r110');
    ax = get(surf, 'Parent');
    callback = get(fig, 'WindowScrollWheelFcn');
    callback(fig, struct('VerticalScrollCount', 1000));
    assert(get(ax, 'CameraViewAngle') == 140);
    callback(fig, struct('VerticalScrollCount', -1000));
    assert(get(ax, 'CameraViewAngle') == 5);
    callback = get(fig, 'WindowKeyPressFcn');
    callback(fig, struct('Key', 'escape'));
    assert(~isgraphics(fig));
    fprintf('PASS: sample image, default layout/string path, zoom bounds, Escape\n');

    top = zeros(32, 64, 3, 'uint8'); top(:, :, 1) = 255;
    bottom = zeros(32, 64, 3, 'uint8'); bottom(:, :, 3) = 255;
    ouFile = fullfile(output, 'over_under.png');
    sbsFile = fullfile(output, 'side_by_side.png');
    imwrite(cat(1, top, bottom), ouFile);
    imwrite(cat(2, top, bottom), sbsFile);
    SphericalImageViewer(2, ouFile);
    fig = gcf; assert(isequal(get(findobj(fig, 'Type', 'surface'), 'CData'), top));
    close(fig);
    SphericalImageViewer(3, sbsFile);
    fig = gcf; assert(isequal(get(findobj(fig, 'Type', 'surface'), 'CData'), top));
    close(fig);
    oddFile = fullfile(output, 'odd.png');
    imwrite(zeros(33, 65, 3, 'uint8'), oddFile);
    mustFail(@() SphericalImageViewer(2, oddFile));
    mustFail(@() SphericalImageViewer(3, oddFile));
    fprintf('PASS: OU/SBS eye selection and odd split rejection\n');

    % A one-frame movie must actually display its first and only frame.
    oneFrame = fullfile(output, 'one_frame.avi');
    writer = VideoWriter(oneFrame, 'Uncompressed AVI');
    writer.FrameRate = 10; open(writer); writeVideo(writer, top); close(writer);
    SphericalVideoViewer(1, oneFrame);
    fig = gcf;
    assert(isequal(get(findobj(fig, 'Type', 'surface'), 'CData'), top));
    close(fig);
    fprintf('PASS: first/only video frame remains inspectable at end\n');

    info = VideoReader(moviefile);
    assert(info.Width == 3840 && info.Height == 3840 && abs(info.FrameRate - 50) < 0.01);
    assert(abs(info.Duration - 9) < 0.03);
    file = dir(moviefile); assert(file.bytes < 100000000);
    t = timer('StartDelay', 1, 'TimerFcn', @(src, event) closeVideo(src, event, originals));
    timerCleanup = onCleanup(@() delete(t));
    start(t);
    SphericalViewer(2, moviefile);
    remaining = findall(groot, 'Type', 'figure', '-regexp', 'Name', '^Spherical Video:');
    assert(all(ismember(remaining, originals)));
    fprintf('PASS: sample video metadata and closing during playback\n');
    fprintf('PTB rendering, physical mouse input, audio, and display timing require separate checks.\n');

end

function closeVideo(~, ~, originals)
    figures = findall(groot, 'Type', 'figure', '-regexp', 'Name', '^Spherical Video:');
    for n = 1:numel(figures)
        if ~ismember(figures(n), originals), close(figures(n)); end
    end
end

function restoreState(oldVisible, originals)
    figures = findall(groot, 'Type', 'figure');
    for n = 1:numel(figures)
        if ~any(figures(n) == originals), delete(figures(n)); end
    end
    set(groot, 'DefaultFigureVisible', oldVisible);
end

function mustFail(callback)
    didFail = false;
    try callback(); catch, didFail = true; end
    assert(didFail, 'Expected invalid input to raise an error.');
end
