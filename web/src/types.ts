/* global EmscriptenModule */

import { FFAVCDecoder } from './ffavc-decoder';
import { FFAVCDecoderFactory } from './ffavc-decoder-factory';

export interface FFAVC extends EmscriptenModule {
  _FFAVCDecoder: any;
  FFAVCDecoderFactory: typeof FFAVCDecoderFactory;
  FFAVCDecoder: typeof FFAVCDecoder;
}

export interface PAG extends EmscriptenModule {
  PAG: PAG;
}
