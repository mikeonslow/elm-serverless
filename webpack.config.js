const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
module.exports = {
  entry: "./src/js/app.js",

  output: {
    publicPath: __dirname + "./dist",
    filename: "js/app.js"
  },

  resolve: {
    extensions: [".js", ".elm", ".css"]
  },

  module: {
    rules: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        use: {
          loader: "raw-loader"
        }
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            debug: false
          }
        }
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      },
      {
        test: /\.(eot|woff|woff2|svg|tff|ttf|otf|png)(.*)$/,
        loader: "file-loader"
      },
      {
        test: /\.scss$/,
        use: [
          {
            loader: "style-loader" // creates style nodes from JS strings
          },
          {
            loader: "css-loader" // translates CSS into CommonJS
          },
          {
            loader: "sass-loader" // compiles Sass to CSS
          }
        ]
      }
    ]
  },
  plugins: [
    new UglifyJsPlugin({
      uglifyOptions: { mangle: true }
    }),
    new CopyWebpackPlugin([{ from: "src/index.html", to: "." }])
  ]
};
