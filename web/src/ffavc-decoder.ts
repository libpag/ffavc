export class FFAVCDecoder {
  private wasmIns: any;

  public constructor(wasmIns: any) {
    this.wasmIns = wasmIns;
  }

  public onConfigure(
      headers: Uint8Array[], mimeType: string, width: number,
      height: number): boolean {
    return this.wasmIns._onConfigure(mimeType, width, height);
  }

  public onSendBytes(bytes: Uint8Array, timestamp: number): number {
    throw new Error('Virtual functions.');
  }

  public onDecodeFrame(): number {
    return this.wasmIns.onDecodeFrame();
  }

  public onEndOfStream(): number {
    return this.wasmIns.onEndOfStream();
  }

  public onFlush() {
    this.wasmIns.onFlush();
  }

  public onRenderFrame() {
    throw new Error('Virtual functions.');
  }
}
