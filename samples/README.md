# Sample 360-degree VR media

Both samples were created in 2025 at Hiroshi Ban's request for research use.
Copyright and portrait/personality-rights permissions for public distribution
have been cleared by Hiroshi Ban. Reuse is governed by
[CC BY-NC 4.0](LICENSE.md).

| File | Subject | Stored dimensions | Input layout | MATLAB argument |
| --- | --- | --- | --- | --- |
| `sample_360deg_VR_image.jpg` | Banyan tree, Okinawa, Japan | 5760 x 2880 px | Mono equirectangular; already extracted from the original stereo material | `videoType = 1` |
| `sample_360deg_VR_movie.mp4` | Walking on a beach, Iki, Japan | 3840 x 3840 px, 50 fps | Over-under stereo; each eye is 3840 x 1920 px | `videoType = 2` |

The image is approximately 4.90 MB. Despite the `OU` text in its original
filename, it contains one complete panorama and must **not** be cropped again.

The movie is the opening **9.00 seconds** of a 50.09-second recording.
It is approximately **93.82 MB (89.47 MiB)** and contains 450 video frames.
The H.264 video and AAC stereo audio were copied without re-encoding; the
resolution, frame rate, and encoded audiovisual quality are retained.
Standard MATLAB playback is silent; the PTB viewer enables audio.

Run these commands from the repository root:

```matlab
SphericalViewer(1, fullfile('samples', 'sample_360deg_VR_image.jpg'));
SphericalViewer(2, fullfile('samples', 'sample_360deg_VR_movie.mp4'));
```

Both stereo layouts are inspected through one eye only (top for over-under,
left for side-by-side). The viewers do not drive an HMD or present binocular
stereo. The input layout is selected explicitly, not inferred from filenames
or MP4 metadata.

## Preparation record

The original files were named:

- `BanyanTree_Okinawa_2025_5760OU_160Mbps_snapshot_5760x2880.jpg`
- `Beach_walking_Iki_2025_3840OU_80Mbps.mp4`

The JPEG was renamed without changing its bytes. The MP4 was shortened with
FFmpeg 4.2.2 using stream copy, then renamed:

```shell
ffmpeg -i Beach_walking_Iki_2025_3840OU_80Mbps.mp4 -t 9 \
  -map 0:v:0 -map 0:a:0 -c copy -movflags +faststart sample_360deg_VR_movie.mp4
```

The full original video and the earlier programs are retained locally under
`backups/`, which is excluded from Git. FFmpeg is a preparation tool and is
not needed to run SphericalViewer.
