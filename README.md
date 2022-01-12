# ffavc

ffavc is a video decoder built on ffmpeg which allows libpag to use ffmpeg as its software decoder
for h264 decoding.

## Building

First, make sure you have built the ffmpeg vendor libraries. For Windows platform, you need to configure 
environment dependencies, run `build_ffmpeg.sh`, for other platforms, run `build_ffmpeg.sh`. The script 
will generate ffmpeg libraries to `vendor/ffmpeg` directory. Then you can open this project by CLion, or 
build it with the cmake command-line tool.

### windows build
Compiling FFmpeg under windows needs to depend on some environments. The specific steps are as follows

1. install [<font color=blue>mysy2</font>](https://www.msys2.org/) 

2. install Visual Studio. It is recommended not to be lower than the 2015 version

3. install some dependencies

    `pacman -S make gcc diffutils mingw-w64-{i686,x86_64}-pkg-config mingw-w64-i686-nasm mingw-w64-i686-yasm`
  
4. re-command link (rename msys64/usr/bin/link.exe to msys64/usr/bin/link.bak, to avoid conflict with MSVC's
 link.exe)

5. run "VS2015 x86 Native Tools Command Prompt" (start the corresponding command according to the installed 
VS version, if 64-bit open 64)

6. jump to the mingw installation directory and run 
   C:\workspace\windows\msys64\msys2_shell.cmd -mingw32 -use-full-path (-mingw64 for 64-bit)

7. switch ffavc root directory, run `build_ffmpeg.sh` 


