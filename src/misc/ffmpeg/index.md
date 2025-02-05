---
title: FFmpeg Cheat Sheet
date: February 3, 2025
description: Random ffmpeg incantations I find useful
---

Apply a gaussian blur:

```bash
ffmpeg -i in.mp4  -vf 'gblur=sigma=20:steps=5' -c:a copy out.mp4
```

Create a video from an audio file and still image:

```bash
ffmpeg -loop 1 -i image.jpg -i audio.m4a -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest out.mp4
```

Crop 200px from the bottom of a video, maintaining aspect ratio:

```bash
ffmpeg -i in.mp4 -filter:v 'crop=iw-200:ih-200:(iw-ow)/2:0' -c:a copy out.mp4
```
