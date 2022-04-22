## ffavc

ffavc is a video decoder built on ffmpeg which allows libpag to use ffmpeg as its software decoder for h264 decoding.

## Quick start

```html
<script src="https://unpkg.com/libpag@latest/lib/libpag.min.js"></script>
<script src="https://unpkg.com/ffavc@latest/lib/ffavc.min.js"></script>
<script>
  window.onload = async () => {
    // Initialize pag webassembly module.
    const PAG = await window.libpag.PAGInit();
    // Initialize ffavc webassembly module.
    const FFAVC = await window.ffavc.FFAVCInit();
    const ffavcDecoderFactory = new FFAVC.FFAVCDecoderFactory();
    PAG.registerSoftwareDecoderFactory(ffavcDecoderFactory);
  };
</script>
```
