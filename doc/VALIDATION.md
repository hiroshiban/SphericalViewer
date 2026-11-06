# Validation record

Date: **2026-11-07**. This record describes publication-preparation checks,
not validation of an experimental stimulus-presentation protocol.

## Environment

- Windows, MATLAB **R2023b Update 11** (`23.2.0.3097123`).
- Installed Psychtoolbox reports **3.0.19**, beta, SVN revision 14005.
  Its presence/API help was checked; fullscreen PTB rendering was not exercised.
- The automated MATLAB graphics context exposes **Microsoft GDI Generic,
  OpenGL 1.1**, with a maximum texture dimension of 1024 pixels. The standard
  viewer's screenshot is therefore a limited-resolution software-rendered
  preview. This does not establish full-resolution GPU rendering performance.
- FFmpeg 4.2.2 was used for sample trimming and independent decoding.

## Completed checks

`validate_SphericalViewer.m` runs against the public functions without
opening a PTB fullscreen window. All checks below passed:

| Check | Result |
| --- | --- |
| MATLAB Code Analyzer, nine root/private `.m` files | No reported issues |
| Invalid layout values, NaN/fractional inputs, unknown renderer, and missing files | Rejected before opening a display or initializing PTB |
| Sample JPEG dimensions and the default mono layout | 5760 x 2880 RGB; all pixels passed through to the surface |
| MATLAB string path input | Accepted |
| Synthetic OU/SBS images | Exactly the top/left eye selected |
| Odd pixel dimensions in the split direction | Rejected |
| Scroll callback at extreme values | Field of view clamped to 5–140 degrees |
| Escape callback | Closed the image figure |
| One-frame uncompressed video | First/only frame displayed and left open at EOF |
| Shortened sample through `VideoReader` | 3840 x 3840, 50 fps, approximately 9.00 seconds |
| Closing the sample video during playback using a timer | Returned without updating deleted graphics handles |
| Sample file size | 93,817,876 bytes; below both 100 MB and GitHub's 100 MiB limit |

Additional preparation checks:

- FFmpeg decoded **all 450 video frames and the audio** of the final excerpt
  without reporting decoding errors. The streams were copied, not re-encoded.
- The original 50.09-second, 524,516,045-byte video is retained in the ignored
  local `backups/` directory.
- The MATLAB perspective preview was visually inspected. A central rendering
  artifact in the software graphics context was resolved by using the axes'
  `childorder` sorting mode for the single textured surface. The panorama is
  upright, with its central region visible in the initial view.
- The generated concept illustration was visually reviewed for the requested
  soft clip-art appearance, headset, person, and surrounding panoramic landscape.

To reproduce the MATLAB checks from the repository root:

```matlab
addpath('doc');
validate_SphericalViewer;
```

Generated fixtures and the preview are written under `.runtime/`, which is
excluded from Git. The public README preview is copied separately into
`doc/images/sample_view.jpg`. Source inspection of the PTB cleanup guards
and texture-coordinate conversion is not a substitute for running that path.

## Remaining interactive/hardware checks

Before a public release, check these on the intended system:

1. Open each supplied sample in the standard MATLAB viewer. Drag through the
   horizon, poles, and panorama seam; check orientation, mouse-wheel direction,
   window resizing, Escape, and closing during playback.
2. Run both PTB viewers on the intended display/GPU. Check fullscreen rendering,
   image and movie texture orientation, OU/SBS eye selection, and the full
   field-of-view range. The old PTB image/movie paths used different texture
   transforms; the shared renderer now uses PTB's pixel-to-texture mapping.
3. Check physical mouse dragging and wheel input. On Windows, confirm raw
   valuators are available; otherwise use keyboard zoom. Check Escape and
   resource release after a movie-decoding error or interrupted playback.
4. Listen to PTB movie audio and check end-of-file behavior. The standard
   MATLAB viewer intentionally does not play audio.
5. For timing-critical experiments, validate onset, frame pacing, audio/video
   synchronization, and display calibration independently. This package does
   not record timing, triggers, or participant responses.

The current automated checks do not establish compatibility with other MATLAB
versions, macOS, Linux, GNU Octave, HMDs, or stereo display hardware.
