cmake_minimum_required(VERSION 3.1)
project(ffavc)

# Options for building ffavc
option(FFAVC_BUILD_STATIC "Build static lib" OFF)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_VERBOSE_MAKEFILE ON)


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

if (APPLE)

    add_compile_options(-stdlib=libc++)
    # hide symbols.
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -w -exported_symbols_list ${CMAKE_CURRENT_SOURCE_DIR}/ios/ffavc.lds")
    list(APPEND FFAVC_VENDOR_LIBS ${CMAKE_CURRENT_SOURCE_DIR}/vendor/ffmpeg/mac/libavcodec.a)
    list(APPEND FFAVC_VENDOR_LIBS ${CMAKE_CURRENT_SOURCE_DIR}/vendor/ffmpeg/mac/libavutil.a)

elseif (ANDROID)

    # optimizes the output size
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/android/ffavc/export.def")
    add_compile_options(-ffunction-sections -fdata-sections -Os -fno-exceptions -fno-rtti)

    list(APPEND FFAVC_FILES src/platform/android/JDecoderFactory.cpp)
    find_library(LOG_LIB log)
    list(APPEND FFAVC_VENDOR_LIBS ${LOG_LIB})
    list(APPEND FFAVC_VENDOR_LIBS ${CMAKE_CURRENT_SOURCE_DIR}/vendor/ffmpeg/android/${ANDROID_ABI}/libavcodec.a)
    list(APPEND FFAVC_VENDOR_LIBS ${CMAKE_CURRENT_SOURCE_DIR}/vendor/ffmpeg/android/${ANDROID_ABI}/libavutil.a)

endif ()

if (FFAVC_BUILD_STATIC)
    add_library(ffavc STATIC ${FFAVC_FILES})
else ()
    add_library(ffavc SHARED ${FFAVC_FILES})
endif ()
target_include_directories(ffavc PUBLIC ${FFAVC_INCLUDES})
target_link_libraries(ffavc ${FFAVC_VENDOR_LIBS})