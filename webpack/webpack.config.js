const webpack = require('webpack')
// const { LoaderOptionsPlugin, ContextReplacementPlugin, DefinePlugin } = webpack

const autoprefixer = require('autoprefixer')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const path = require('path')
const rootPath = path.join(__dirname, '..')


const ENVIRONMENTS = [
  'development',
  'production',
  'testrunner'
]

const isDev = (env) => env === 'development'

module.exports =  (env) => {
  console.log("Webpack: environment:", env)
  if (!ENVIRONMENTS.includes(env))
    throw new Error(`Environment ${env} is not supported.`)

  return {
    target: 'web',
    devtool: isDev(env) ? 'source-map' : 'nosources-source-map',
    mode: env,
    entry: './webpack/app.js',
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
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: "css-loader",
              options: {
                modules: true,
                sourceMap: true,
                importLoader: 2,
                minimize: !isDev(env),
                camelCase: true,
                localIdentName: isDev(env) ? "[name]__[local]___[hash:base64:5]" : "[hash:base64]"
              }
            },
            'sass-loader',
          ]
        },
        {
          test: /\.(eot|svg|ttf|woff|woff2|png|gif)$/,
          loader: 'file-loader?name=[name].[ext]',
        },
      ],
    },
    resolve: {
      modules: ['webpack/', 'node_modules/'],
      extensions: ['.js', 'jsx']
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: "stylesheets/[name].css",
        chunkFilename: "stylesheets/[id].css"
      })
    ],
  }
}
