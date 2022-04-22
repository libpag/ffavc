import { FFAVC } from './types';

export interface YUVBuffer {
  data: number[];
  lineSize: number[];
}

export const enum DecoderResult {
  /**
   * The calling is successful.
   */
  Success = 0,
  /**
   * Output is not available in this state, need more input buffers.
   */
  TryAgainLater = -1,
  /**
   * The calling fails.
   */
  Error = -2,
}

const YUV_BUFFER_LENGTH = 3;

export class FFAVCDecoder {
  public static module: FFAVC;

  private wasmIns: any;
  private pag: any;
  private height = 0;
  private buffer: YUVBuffer = { data: [], lineSize: [] };

  public constructor(wasmIns: any, pag: any) {
    this.wasmIns = wasmIns;
    this.pag = pag;
  }

  public onConfigure(headers: Uint8Array[], mimeType: string, width: number, height: number): boolean {
    this.height = height;
    const dataOnHeaps = headers.map((header) => {
      const length = header.byteLength * header.BYTES_PER_ELEMENT;
      const dataPtr = FFAVCDecoder.module._malloc(length);
      const dataOnFFAVC = new Uint8Array(FFAVCDecoder.module.HEAP8.buffer, dataPtr, length);
      dataOnFFAVC.set(header);
      return dataOnFFAVC;
    });
    const res = this.wasmIns._onConfigure(dataOnHeaps, mimeType, width, height) as boolean;
    dataOnHeaps.forEach((data) => {
      FFAVCDecoder.module._free(data.byteOffset);
    });
    return res;
  }

  public onSendBytes(bytes: Uint8Array, timestamp: number): DecoderResult {
    const length = bytes.byteLength * bytes.BYTES_PER_ELEMENT;
    const dataPtr = FFAVCDecoder.module._malloc(length);
    const dataOnFFAVC = new Uint8Array(FFAVCDecoder.module.HEAP8.buffer, dataPtr, length);
    dataOnFFAVC.set(bytes);
    const res = this.wasmIns._onSendBytes(dataOnFFAVC, timestamp).value;
    FFAVCDecoder.module._free(dataPtr);
    return res;
  }

  public onDecodeFrame(): DecoderResult {
    return this.wasmIns._onDecodeFrame().value;
  }

  public onEndOfStream(): DecoderResult {
    return this.wasmIns._onEndOfStream().value;
  }

  public onFlush() {
    this.wasmIns._onFlush();
  }

  public onRenderFrame(): YUVBuffer {
    // Free last frame.
    if (this.buffer.data.length > 0) {
      this.buffer.data.forEach((data) => {
        this.pag._free(data);
      });
    }
    const buffer = this.wasmIns._onRenderFrame() as YUVBuffer;
    // Copy data from FFAVCModule to PAGModule
    for (let index = 0; index < YUV_BUFFER_LENGTH; index++) {
      const length = buffer.lineSize[index] * this.height;
      const dataOnFFAVC = new Uint8Array(FFAVCDecoder.module.HEAP8.buffer, buffer.data[index], length);
      const dataPtr = this.pag._malloc(length);
      const dataOnPAG = new Uint8Array(this.pag.HEAP8.buffer, dataPtr, length);
      dataOnPAG.set(dataOnFFAVC);
      this.buffer.data[index] = dataPtr;
      this.buffer.lineSize[index] = buffer.lineSize[index];
    }
    return this.buffer;
  }

  public onRelease() {
    if (this.buffer.data.length > 0) {
      this.buffer.data.forEach((data) => {
        this.pag._free(data);
      });
    }
    this.wasmIns.delete();
  }
}
