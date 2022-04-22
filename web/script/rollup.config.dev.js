import esbuild from 'rollup-plugin-esbuild';
import resolve from '@rollup/plugin-node-resolve';
import commonJs from '@rollup/plugin-commonjs';

export default [
  {
    input: 'demo/index.ts',
    output: { file: 'demo/index.js', format: 'esm', sourcemap: true },
    plugins: [esbuild({ tsconfig: 'tsconfig.json', minify: false }), resolve(), commonJs()],
  },
];
