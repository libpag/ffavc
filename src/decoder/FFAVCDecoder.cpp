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

#include "FFAVCDecoder.h"
#include "ffavc.h"

namespace ffavc {

#define I420_PLANE_COUNT 3

FFAVCDecoder::~FFAVCDecoder() { closeDecoder(); }

bool FFAVCDecoder::onConfigure(const std::vector<pag::HeaderData>& headers, std::string mimeType,
                               int, int) {
  if (mimeType != "video/avc") {
    return false;
  }
  size_t headerLength = 0;
  for (auto& header : headers) {
    headerLength += header.length;
  }
  auto headerData = new uint8_t[headerLength];
  size_t pos = 0;
  for (auto& header : headers) {
    memcpy(headerData + pos, header.data, header.length);
    pos += header.length;
  }
  auto isValid = openDecoder(headerData, headerLength);
  delete[] headerData;
  return isValid;
}

bool FFAVCDecoder::openDecoder(uint8_t* headerData, size_t headerLength) {
  codec = avcodec_find_decoder(AVCodecID::AV_CODEC_ID_H264);
  if (!codec) {
    return false;
  }
  context = avcodec_alloc_context3(codec);
  if (!context) {
    return false;
  }
  AVCodecParameters parameters = {};
  parameters.extradata = headerData;
  parameters.extradata_size = static_cast<int>(headerLength);
  // h264 解码需要设置 video_delay，否则含有B帧视频解码可能会出第一个B帧无法解码成功。
  parameters.video_delay = 1;
  if ((avcodec_parameters_to_context(context, &parameters)) < 0) {
    return false;
  }
  if (avcodec_open2(context, codec, nullptr) < 0) {
    return false;
  }
  packet = av_packet_alloc();
  if (packet == nullptr) {
    return false;
  }
  frame = av_frame_alloc();
  return frame != nullptr;
}

void FFAVCDecoder::closeDecoder() {
  if (context != nullptr) {
    avcodec_free_context(&context);
    context = nullptr;
  }
  if (frame != nullptr) {
    av_frame_free(&frame);
  }
  if (packet != nullptr) {
    av_packet_free(&packet);
  }
}

pag::DecoderResult FFAVCDecoder::onSendBytes(void* bytes, size_t length, int64_t) {
  if (context == nullptr) {
    return pag::DecoderResult::Error;
  }
  packet->data = static_cast<uint8_t*>(bytes);
  packet->size = static_cast<int>(length);
  auto result = avcodec_send_packet(context, packet);
  if (result >= 0 || result == AVERROR_EOF) {
    return pag::DecoderResult::Success;
  } else if (result == AVERROR(EAGAIN)) {
    return pag::DecoderResult::TryAgainLater;
  } else {
    return pag::DecoderResult::Error;
  }
}

pag::DecoderResult FFAVCDecoder::onDecodeFrame() {
  auto result = avcodec_receive_frame(context, frame);
  if (result >= 0 && frame->data[0] != nullptr) {
    return pag::DecoderResult::Success;
  } else if (result == AVERROR(EAGAIN)) {
    return pag::DecoderResult::TryAgainLater;
  } else {
    return pag::DecoderResult::Error;
  }
}

pag::DecoderResult FFAVCDecoder::onEndOfStream() { return onSendBytes(nullptr, 0, -1); }

void FFAVCDecoder::onFlush() { avcodec_flush_buffers(context); }

std::unique_ptr<pag::YUVBuffer> FFAVCDecoder::onRenderFrame() {
  auto buffer = std::make_unique<pag::YUVBuffer>();
  for (int i = 0; i < I420_PLANE_COUNT; i++) {
    buffer->data[i] = frame->data[i];
    buffer->lineSize[i] = frame->linesize[i];
  }
  return buffer;
}

void* DecoderFactory::GetHandle() {
  static auto factory = *new FFAVCDecoderFactory();
  return &factory;
}
}  // namespace ffavc
