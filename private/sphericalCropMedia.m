function img = sphericalCropMedia(raw, videoType)
% Select the top or left eye; no binocular display is performed.
% Copyright (c) 2026, Hiroshi Ban. See LICENSE.txt (BSD-2-Clause).
    [h, w, ~] = size(raw);
    switch videoType
        case 2
            if mod(h, 2) ~= 0
                error('SphericalViewer:OddStereoSize', ...
                    'Over-under media must have an even pixel height.');
            end
            img = raw(1:h/2, :, :);
        case 3
            if mod(w, 2) ~= 0
                error('SphericalViewer:OddStereoSize', ...
                    'Side-by-side media must have an even pixel width.');
            end
            img = raw(:, 1:w/2, :);
        otherwise
            img = raw;
    end
end
