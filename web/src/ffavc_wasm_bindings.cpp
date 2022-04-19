/////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Tencent is pleased to support the open source community by making libpag available.
//
//  Copyright (C) 2021 THL A29 Limited, a Tencent company. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  unless required by applicable law or agreed to in writing, software distributed under the
//  license is distributed on an "as is" basis, without warranties or conditions of any kind,
//  either express or implied. see the license for the specific language governing permissions
//  and limitations under the license.
//
/////////////////////////////////////////////////////////////////////////////////////////////////

#include <emscripten/bind.h>
#include <emscripten/val.h>
#include "decoder/FFAVCDecoder.h"

using namespace emscripten;
using namespace pag;
using namespace ffavc;

EMSCRIPTEN_BINDINGS(ffavc) {
  class_<FFAVCDecoder>("_FFAVCDecoder")
      .smart_ptr<std::shared_ptr<FFAVCDecoder>>("_FFAVCDecoder")
      .function("_onConfigure", &FFAVCDecoder::onConfigure)
      .function("_onSendBytes",
                optional_override([](FFAVCDecoder& decoder, intptr_t bytes, int length, int frame) {
                  return decoder.onSendBytes(reinterpret_cast<uint8_t*>(bytes),
                                             static_cast<size_t>(length),
                                             static_cast<int64_t>(frame));
                }))
      .function("_onDecodeFrame", &FFAVCDecoder::onDecodeFrame)
      .function("_onEndOfStream", &FFAVCDecoder::onEndOfStream)
      .function("_onFlush", &FFAVCDecoder::onFlush)
      .function("_onRenderFrame", optional_override([](FFAVCDecoder& decoder) {
                  auto buffer = decoder.onRenderFrame();
                  if (buffer == nullptr) {
                    return val::null();
                  }
                  auto dataArray = val::array();
                  dataArray.call<void>("push", reinterpret_cast<intptr_t>(buffer->data[0]),
                                       reinterpret_cast<intptr_t>(buffer->data[1]),
                                       reinterpret_cast<intptr_t>(buffer->data[2]));
                  auto lineSizeArray = val::array();
                  lineSizeArray.call<void>("push", buffer->lineSize[0], buffer->lineSize[1],
                                           buffer->lineSize[2]);
                  auto ret = val::object();
                  ret.set("data", dataArray);
                  ret.set("lineSize", lineSizeArray);
                  return ret;
                }));

  enum_<DecoderResult>("DecoderResult")
      .value("Success", DecoderResult::Success)
      .value("TryAgainLater", DecoderResult::TryAgainLater)
      .value("Error", DecoderResult::Error);

  value_object<HeaderData>("HeaderData")
      .field("data", optional_override([](const HeaderData& header) {
               return reinterpret_cast<intptr_t>(header.data);
             }),
             optional_override([](HeaderData& header, intptr_t value) {
               header.data = reinterpret_cast<uint8_t*>(value);
             }))
      .field("length", &HeaderData::length);

  register_vector<HeaderData>("VectorHeaderData");
}
