cmake_minimum_required(VERSION 3.1)
project(ffavc)

# Options for building ffavc
if (EMSCRIPTEN)
    option(FFAVC_BUILD_STATIC "Build static lib" ON)
else ()
    option(FFAVC_BUILD_STATIC "Build static lib" OFF)
endif ()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_VERBOSE_MAKEFILE ON)

if (EMSCRIPTEN)
    set(ARCH wasm)
elseif (ANDROID OR IOS)
    if (CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
        if (SDK_NAME STREQUAL iphonesimulator)
            set(ARCH arm64-simulator)
        else ()
            set(ARCH arm64)
        endif ()
    elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(ARCH x64)
    else ()
        set(ARCH arm)
    endif ()
else ()
    if (MSVC)
        string(TOLOWER ${MSVC_C_ARCHITECTURE_ID} ARCH)
    elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" OR $CMAKE_SYSTEM_PROCESSOR STREQUAL "amd64")
        set(ARCH x64)
    elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
        set(ARCH arm64)
    else ()
        set(ARCH x86)
    endif ()
endif ()

if (EMSCRIPTEN)
    set(WEB TRUE)
    set(PLATFORM web)
elseif (ANDROID)
    set(PLATFORM android)
    set(ENV{NDK_HOME} ${ANDROID_NDK})
elseif (IOS)
    set(PLATFORM ios)
elseif (APPLE)
    set(MACOS TRUE)
    set(PLATFORM mac)
elseif (WIN32)
    set(PLATFORM win)
elseif (CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
    set(LINUX TRUE)
    set(PLATFORM linux)
endif ()


# Sets the default build type to release.
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_definitions(-Werror -Wall -Wextra -Weffc++ -pedantic -Werror=return-type)
endif ()

if (MSVC)
    add_compile_options("/utf-8")
endif (MSVC)

# Sets flags
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-DFFAVC_DEBUG)
endif ()

# collects include directories.
set(FFAVC_INCLUDES ./ include src vendor/libpag/include vendor/ffmpeg/include)

# collects source files.
set(FFAVC_FILES src/decoder/FFAVCDecoder.cpp)

add_compile_options(-fvisibility=hidden)

file(GLOB FFMPEG_FILES vendor/ffmpeg/${PLATFORM}/${ARCH}/*${CMAKE_STATIC_LIBRARY_SUFFIX})
list(APPEND FFAVC_VENDOR_LIBS ${FFMPEG_FILES})

if (APPLE)

    add_compile_options(-stdlib=libc++)
    # hide symbols.
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -w -exported_symbols_list ${CMAKE_CURRENT_SOURCE_DIR}/ios/ffavc.lds")

elseif (ANDROID)

    # optimizes the output size
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/android/ffavc/export.def")
    add_compile_options(-ffunction-sections -fdata-sections -Os -fno-exceptions -fno-rtti)

    list(APPEND FFAVC_FILES src/platform/android/JDecoderFactory.cpp)
    find_library(LOG_LIB log)
    list(APPEND FFAVC_VENDOR_LIBS ${LOG_LIB})

endif ()

if (FFAVC_BUILD_STATIC)
    add_library(ffavc STATIC ${FFAVC_FILES})
else ()
    add_library(ffavc SHARED ${FFAVC_FILES})
endif ()
target_include_directories(ffavc PUBLIC ${FFAVC_INCLUDES})
target_link_libraries(ffavc ${FFAVC_VENDOR_LIBS})