const path = require("path");
const dotenv = require("dotenv");
const webpack = require("webpack");
const outputPath = path.resolve(__dirname, "dist");
const HtmlWebPackPlugin = require("html-webpack-plugin");

const env = dotenv.config().parsed;

module.exports = {
  mode: env.MODE,
  entry: "./src/main.ts",
  output: {
    filename: "main.js",
    path: outputPath,
  },
  devServer: {
    contentBase: outputPath,
    port: 3000,
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: "ts-loader",
      },
      {
        test: /\.html$/,
        loader: "html-loader",
      },
    ],
  },
  resolve: {
    extensions: [".ts", ".js"],
    modules: [path.resolve("./node_modules")],
  },
  plugins: [
    new webpack.DefinePlugin({
      "process.env": JSON.stringify(env),
    }),
    new HtmlWebPackPlugin({
      template: "./src/index.html",
      filename: "./index.html",
    }),
  ],
};
