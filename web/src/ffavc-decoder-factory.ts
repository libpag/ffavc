import { FFAVC } from './ffavc';
import { FFAVCDecoder } from './ffavc-decoder';

export class FFAVCDecoderFactory {
  public static module: FFAVC;

  public createSoftwareDecoder(): FFAVCDecoder {
    const wasmIns = new FFAVCDecoderFactory.module._FFAVCDecoder();
    return new FFAVCDecoder(wasmIns);
  }
}
