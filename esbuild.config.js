const build = require("./config/esbuild.defaults.js")

// You can customize this as you wish, perhaps to add new esbuild plugins.
//
// ```
// const path = require("path")
// const esbuildCopy = require('esbuild-plugin-copy').default
// const esbuildOptions = {
//   plugins: [
//     esbuildCopy({
//       assets: {
//         from: [path.resolve(__dirname, 'node_modules/somepackage/files/*')],
//         to: [path.resolve(__dirname, 'output/_bridgetown/somepackage/files')],
//       },
//       verbose: false
//     }),
//   ]
// }
// ```
//
// You can also support custom base_path deployments via changing `publicPath`.
//
// ```
// const esbuildOptions = {
//   publicPath: "/my_subfolder/_bridgetown/static",
//   ...
// }
// ```

/**
 * @typedef { import("esbuild").BuildOptions } BuildOptions
 * @type {BuildOptions}
 */
const esbuildOptions = {
  plugins: [
    // add new plugins here...
  ],
  globOptions: {
    excludeFilter: /\.(dsd|lit)\.css$/
  },
  sassOptions: {
    quietDeps: true,
    silenceDeprecations: ['import']
  }
}

build(esbuildOptions)
