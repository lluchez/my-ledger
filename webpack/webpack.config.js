const webpack = require('webpack')
// const { LoaderOptionsPlugin, ContextReplacementPlugin, DefinePlugin } = webpack

const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const autoprefixer = require('autoprefixer') // for browser specific tags

const path = require('path'),
  rootPath = path.join(__dirname, '..'),
  entryPath = path.join(__dirname, 'app.js'),
  cssPath = path.resolve(__dirname, "css")


const ENVIRONMENTS = [
  'development',
  'production',
  'testrunner'
]

const isDev = (env) => env === 'development'

const cssLoader = (enableModules, env) => {
  const options = {
    sourceMap: true
  }
  const cssLoaderOptions = Object.assign({
    modules: enableModules,
    importLoader: 2,
    minimize: !isDev(env),
    camelCase: enableModules,
    localIdentName: enableModules && (isDev(env) ? "[name]__[local]___[hash:base64:5]" : "[hash:base64]"),
  }, options)

  return [
    MiniCssExtractPlugin.loader,
    {
      loader: "css-loader",
      options: cssLoaderOptions
    },
    {
      loader: 'postcss-loader',
      options: Object.assign({
        plugins: () => [autoprefixer],
      }, options)
    },
    {
      loader: 'sass-loader',
      options: options
    }
  ]
}

module.exports = (env = 'development') => {
  console.log("Webpack: environment:", env)
  if (!ENVIRONMENTS.includes(env))
    throw new Error(`Environment ${env} is not supported.`)

  return {
    target: 'web',
    devtool: isDev(env) ? 'source-map' : 'nosources-source-map',
    mode: env,
    entry: entryPath,
    stats: {
      colors: true
    },
    output: {
      filename: 'javascripts/[name].js',
      path: path.resolve(rootPath, 'public/assets'),
    },
    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          loader: 'babel-loader'
        },
        {
          test: /\.s?css$/,
          exclude: /node_modules/,
          include: [cssPath],
          use: cssLoader(false, env)
        },
        {
          test: /\.s?css$/,
          exclude: [
            /node_modules/, // NOTE: for path separators, use [\/\\] (to also support Windows)
            cssPath
          ],
          use: cssLoader(true, env)
        },
        {
          test: /\.(eot|svg|ttf|woff|woff2|png|gif)$/,
          loader: 'file-loader?name=[name].[ext]',
        },
      ],
    },
    resolve: {
      modules: ['webpack/', 'node_modules/'],
      extensions: ['.js', '.jsx']
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: "stylesheets/[name].css",
        chunkFilename: "stylesheets/[id].css"
      })
    ],
  }
}
