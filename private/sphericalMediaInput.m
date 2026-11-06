function [videoType, filepath] = sphericalMediaInput(videoType, filepath, kind)
% Validate shared viewer arguments before opening a display or input queue.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    if isempty(videoType), videoType = 1; end
    validateattributes(videoType, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'integer', '>=', 1, '<=', 3}, ...
        'SphericalViewer', 'videoType');
    if isempty(filepath)
        switch kind
            case 'image'
                filter = {'*.jpg;*.jpeg;*.png;*.bmp', 'Image files'};
            case 'video'
                filter = {'*.mp4;*.mov;*.avi;*.m4v', 'Video files'};
            otherwise
                filter = {'*.jpg;*.jpeg;*.png;*.bmp;*.mp4;*.mov;*.avi;*.m4v', ...
                    '360-degree images and videos'};
        end
        [filename, folder] = uigetfile(filter, 'Select 360-degree media');
        if isequal(filename, 0), filepath = ''; return; end
        filepath = fullfile(folder, filename);
    end
    if isstring(filepath) && isscalar(filepath), filepath = char(filepath); end
    validateattributes(filepath, {'char'}, {'row', 'nonempty'}, ...
        'SphericalViewer', 'filepath');
    if ~isfile(filepath)
        error('SphericalViewer:FileNotFound', 'File not found: %s', filepath);
    end
end
