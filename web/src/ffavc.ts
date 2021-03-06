/* global EmscriptenModule */

import { FFAVCDecoder } from './ffavc-decoder';
import { FFAVCDecoderFactory } from './ffavc-decoder-factory';
import { FFAVC } from './types';
import createFFAVC from './wasm/ffavc';

export interface moduleOption {
  /**
   * Link to wasm file.
   */
  locateFile?: (file: string) => string;
}

export const FFAVCInit = (moduleOption: moduleOption = {}): Promise<FFAVC> =>
  createFFAVC(moduleOption).then((module: FFAVC) => {
    binding(module);
    return module;
  });

const binding = (module: FFAVC) => {
  module.FFAVCDecoderFactory = FFAVCDecoderFactory;
  FFAVCDecoderFactory.module = module;
  module.FFAVCDecoder = FFAVCDecoder;
  FFAVCDecoder.module = module;
};
