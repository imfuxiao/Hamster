const { defineConfig } = require("@vue/cli-service");
module.exports = defineConfig({
  transpileDependencies: true,

  // 启动设置
  devServer: {
    // port: 8000,
    // 代理
    proxy: {
      // 请求的根路径
      "/api": {
        // 跨域请求的目标地址
        target: "http://127.0.0.1",
        // 路径重写
        pathRewrite: {
          // 以正则匹配 开头/api
          "^/api": "/api",
        },
      },
    },
  },
});

// const CompressionPlugin = require("compression-webpack-plugin");

// module.exports = {
//   runtimeCompiler: true,
//   publicPath: "/",
//   parallel: 2,
//   configureWebpack: {
//     plugins: [
//       new CompressionPlugin({
//         include: /\.js$/,
//         deleteOriginalAssets: true,
//       }),
//     ],
//   },
// };
