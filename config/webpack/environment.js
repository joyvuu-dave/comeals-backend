const { environment } = require("@rails/webpacker");
var SWPrecacheWebpackPlugin = require("sw-precache-webpack-plugin");
const PUBLIC_PATH = "https://www.comeals.test/";
environment.plugins.prepend(
  "SWPrecacheWebpackPlugin",
  new SWPrecacheWebpackPlugin({
    cacheId: "comeals",
    dontCacheBustUrlsMatching: /\.\w{8}\./,
    filename: "service-worker.js",
    minify: true,
    navigateFallback: PUBLIC_PATH + "index.html",
    staticFileGlobsIgnorePatterns: [/\.map$/, /manifest\.json$/],
    maximumFileSizeToCacheInBytes: 1073741824
  })
);

module.exports = environment;
