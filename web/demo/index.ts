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

  const canvas = document.createElement('canvas');
  canvas.width = 375;
  canvas.height = 667;
  document.getElementById('box')?.appendChild(canvas);

  let pagView = await PAG.PAGView.init(pagFile, canvas);
  await pagView?.play();
};
