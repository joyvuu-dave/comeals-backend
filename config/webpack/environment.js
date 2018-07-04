const { environment } = require("@rails/webpacker");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const HtmlWebpackHarddiskPlugin = require("html-webpack-harddisk-plugin");

environment.plugins.append(
  "HtmlWebpack",
  new HtmlWebpackPlugin({
    template: "app/views/layouts/application.html",
    alwaysWriteToDisk: true
  })
);

environment.plugins.append(
  "HtmlWebpackHarddisk",
  new HtmlWebpackHarddiskPlugin({
    outputPath: "public/packs"
  })
);

module.exports = environment;
