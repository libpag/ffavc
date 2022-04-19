import { FFAVC } from './ffavc';

export interface YUVBuffer {
  data: Uint8Array[];
  lineSize: number[];
}

export class FFAVCDecoder {
  public static module: FFAVC;

  private wasmIns: any;

  public constructor(wasmIns: any) {
    this.wasmIns = wasmIns;
  }

  public onConfigure(headers: Uint8Array[], mimeType: string, width: number, height: number): boolean {
    return this.wasmIns._onConfigure(headers, mimeType, width, height) as boolean;
  }

  public onSendBytes(bytes: Uint8Array, timestamp: number): number {
    const numBytes = bytes.byteLength * bytes.BYTES_PER_ELEMENT;
    const dataPtr = FFAVCDecoder.module._malloc(numBytes);
    const dataOnHeap = new Uint8Array(FFAVCDecoder.module.HEAP8.buffer, dataPtr, numBytes);
    dataOnHeap.set(bytes);
    return this.wasmIns._onSendBytes(dataOnHeap.byteOffset, dataOnHeap.byteLength, timestamp) as number;
  }

  public onDecodeFrame(): number {
    return this.wasmIns._onDecodeFrame() as number;
  }

  public onEndOfStream(): number {
    return this.wasmIns._onEndOfStream() as number;
  }

  public onFlush() {
    this.wasmIns._onFlush();
  }

  public onRenderFrame(): YUVBuffer {
    return this.wasmIns._onRenderFrame() as YUVBuffer;
  }
}
