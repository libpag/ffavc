import { FFAVCInit } from '../src/ffavc';

declare global {
  interface Window {
    libpag: any;
  }
}

window.onload = async () => {
  const FFAVC = await FFAVCInit({ locateFile: (file: string) => '../lib/' + file });
  console.log('FFAVC', FFAVC);

  const ffavcDecoderFactory = new FFAVC.FFAVCDecoderFactory();

  const PAG = await window.libpag.PAGInit();
  PAG.registerSoftwareDecoderFactory(ffavcDecoderFactory);

  const buffer = await fetch('./particle_video.pag').then((response) => response.arrayBuffer());
  const pagFile = await PAG.PAGFile.load(buffer);

  const pagCanvas = document.getElementById('pag') as HTMLCanvasElement;

  let pagView = await PAG.PAGView.init(pagFile, pagCanvas);
  await pagView?.play();
};
