import resolve from '@rollup/plugin-node-resolve';
import commonJs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import esbuild from 'rollup-plugin-esbuild';

import pkg from '../package.json';

const umdConfig = {
  input: 'src/ffavc.ts',
  output: [
    {
      name: 'ffavc',
      format: 'umd',
      exports: 'named',
      sourcemap: true,
      file: pkg.browser,
    },
  ],
  plugins: [esbuild({ tsconfig: 'tsconfig.json', minify: false }), json(), resolve(), commonJs()],
};

const umdMinConfig = {
  input: 'src/ffavc.ts',
  output: [
    {
      name: 'ffavc',
      format: 'umd',
      exports: 'named',
      sourcemap: true,
      file: 'lib/ffavc.min.js',
    },
  ],
  plugins: [esbuild({ tsconfig: 'tsconfig.json', minify: false }), json(), resolve(), commonJs(), terser()],
};

export default [
  umdConfig,
  umdMinConfig,
  {
    input: 'src/ffavc.ts',
    output: [
      { file: pkg.module, format: 'esm', sourcemap: true },
      { file: pkg.main, format: 'cjs', exports: 'auto', sourcemap: true },
    ],
    plugins: [esbuild({ tsconfig: 'tsconfig.json', minify: false }), resolve(), commonJs()],
  },
];
