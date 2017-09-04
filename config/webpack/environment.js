const { environment } = require("@rails/webpacker");
const webpack = require("webpack");

environment.plugins.set(
  "CommonsChunkVendor",
  new webpack.optimize.CommonsChunkPlugin({
    name: "vendor",
    minChunks: module => {
      // this assumes your vendor imports exist in the node_modules directory
      return module.context && module.context.indexOf("node_modules") !== -1;
    }
  })
);

environment.plugins.set(
  "CommonsChunkManifest",
  new webpack.optimize.CommonsChunkPlugin({
    name: "manifest",
    minChunks: Infinity
  })
);

module.exports = environment;
