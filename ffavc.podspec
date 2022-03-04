PAG_ROOT = __dir__

Pod::Spec.new do |s|
  s.name     = 'ffavc'
  s.version  = '1.0.0'
  s.ios.deployment_target   = '9.0'
  s.osx.deployment_target   = '10.13'
  s.summary  = 'ffavc is a video decoder built on ffmpeg which allows libpag to use ffmpeg as its software decoder for h264 decoding.'
  s.homepage = "https://pag.io"
  s.author   = { 'dom' => 'dom@idom.me' }
  s.requires_arc = false
  s.source   = {
    :git => 'http://git.woa.com/TAVGroup/ffavc.git'
  }

  s.source_files = 'include/ffavc.h',
                   'src/decoder/**/*.{h,cpp}',
                   'src/cocoa/**/*.{h,cpp,mm,m}'

  s.public_header_files = 'include/ffavc.h'
  s.libraries = ["c++"]
  s.compiler_flags = '-Wno-documentation'
  C_FLAGS = ["-Wall -Wextra -Weffc++ -pedantic -Werror=return-type"]
  s.xcconfig = {"HEADER_SEARCH_PATHS" => "#{PAG_ROOT}/src #{PAG_ROOT}/include #{PAG_ROOT}/vendor/ffmpeg/include #{PAG_ROOT}/vendor/libpag/include","OTHER_CFLAGS" => C_FLAGS.join(" "),"OTHER_LDFLAGS" => "-w","EXPORTED_SYMBOLS_FILE" => "#{PAG_ROOT}/ios/ffavc.lds"}
  s.vendored_frameworks  = 'vendor/ffmpeg/apple/libavcodec.xcframework', 'vendor/ffmpeg/apple/libavutil.xcframework'

end
