///////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2021 Tencent. All rights reserved.
//
//  This library is free software; you can redistribute it and/or modify it under the terms of the
//  GNU Lesser General Public License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
//  the GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License along with this
//  library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
//  Boston, MA  02110-1301  USA
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "pag/decoder.h"

extern "C" {
#include "libavcodec/avcodec.h"
}

namespace ffavc {

/**
 * All input data sent to AVCDecoder must be in annex-b format, and all output buffers from
 * AVCDecoder are in I420 format.
 */
class FFAVCDecoder : public pag::SoftwareDecoder {
 public:
  ~FFAVCDecoder() override;

  bool onConfigure(const std::vector<pag::HeaderData>& headers, std::string mime, int width,
                   int height) override;

  pag::DecoderResult onSendBytes(void* bytes, size_t length, int64_t frame) override;

  pag::DecoderResult onDecodeFrame() override;

  pag::DecoderResult onEndOfStream() override;

  void onFlush() override;

  std::unique_ptr<pag::YUVBuffer> onRenderFrame() override;

 private:
  const AVCodec* codec = nullptr;
  AVCodecContext* context = nullptr;
  AVFrame* frame = nullptr;
  AVPacket* packet = nullptr;

  bool openDecoder(uint8_t* headerData, size_t headerLength);
  void closeDecoder();
};

class FFAVCDecoderFactory : pag::SoftwareDecoderFactory {
 public:
  std::unique_ptr<pag::SoftwareDecoder> createSoftwareDecoder() override {
    return std::unique_ptr<pag::SoftwareDecoder>(new FFAVCDecoder());
  }
};

}  // namespace ffavc
