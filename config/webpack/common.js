// Note: You must restart bin/webpack-watcher for changes to take effect
/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack      = require('webpack')
const autoprefixer = require('autoprefixer')
const csswring     = require('csswring')

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const ManifestPlugin    = require('webpack-manifest-plugin')

const { resolve } = require('path')
const { env, paths, publicPath, loadersDir } = require('./configuration.js')

console.log(publicPath)

module.exports = {
  entry: {
    main: ['main.js', 'main.sass']
  },

  output: {
    path: resolve(paths.output),
    filename: '[name].js',
    chunkFilename: '[name].[id].[chunkhash].js',
    publicPath
  },

  module: {
    rules: [{
      test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: (env.NODE_ENV === 'production' ? '[name]-[hash].[ext]' : '[name].[ext]') }
      }]
    }, {
      test: /\.(scss|sass|css)$/i,
      use: ExtractTextPlugin.extract({
        use: [{
          loader: 'css-loader',
          options: {
            minimize: env.NODE_ENV === 'production',
            importLoaders: 2
          }
        }, {
          loader: 'postcss-loader',
          options: {
            plugins: () => [
              require('autoprefixer'),
              require('csswring')
            ]
          }
        }, {
          loader: 'sass-loader',
          options: {
            includePaths: [
              require('bourbon').includePaths
            ]
          }
        }]
      })
    }, {
      test: /\.(js)$/i,
      use: [{
        loader: 'babel-loader',
        options: {
          presets: ['env']
        }
      }]
    }]
  },

  plugins: [
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(env.NODE_ENV === 'production' ? '[name]-[hash].css' : '[name].css'),
    new ManifestPlugin({ fileName: paths.manifest, writeToFileEmit: true, publicPath }),
    new webpack.optimize.UglifyJsPlugin({sourceMap: true})
  ],

  resolve: {
    extensions: [
      '.coffee', '.js', '.sass', '.scss', '.css', '.png', '.svg', '.jpg'
    ],
    modules: [
      resolve(paths.source),
      resolve(paths.node_modules)
    ]
  },

  resolveLoader: {
    modules: [paths.node_modules]
  }
}