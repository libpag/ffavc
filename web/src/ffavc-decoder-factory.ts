/* global EmscriptenModule */

import { FFAVCDecoder } from './ffavc-decoder';
import { FFAVC } from './types';

export class FFAVCDecoderFactory {
  public static module: FFAVC;

  public createSoftwareDecoder(pag: EmscriptenModule): FFAVCDecoder | null {
    if (!pag) return null;
    const wasmIns = new FFAVCDecoderFactory.module._FFAVCDecoder();
    return new FFAVCDecoder(wasmIns, pag);
  }
}
