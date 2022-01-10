# ffavc

ffavc is a video decoder built on ffmpeg which allows libpag to use ffmpeg as its software decoder
for h264 decoding.

## Building

First, make sure you have built the ffmpeg vendor libraries. For Windows platform,
run `build_ffmpeg.bat`, for other platforms, run `build_ffmpeg.sh`. The script will generate ffmpeg
libraries to `vendor/ffmpeg` directory. Then you can open this project by CLion, or build it with
the cmake command-line tool.
