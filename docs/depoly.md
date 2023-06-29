# maputnik
- 安装完成 `node_modules` 如果 `@mapbox/mapbox-gl-style-spec` 包报错之后，需要修改 `node_modules` 对应的源码，改成 `js` 代码即可编译通过；
- 运行 `node` 版本为 `14.x.x`
## 本地化
如何使用 nginx 部署？
1. 修改 webpack.production.config.js 中的 output 配置，加入 publicPath
```js
output: {
  path: OUTPATH,
  filename: '[name].[contenthash].js',
  chunkFilename: '[contenthash].js',
  publicPath: '/maputnik' // 本地化
}
```

2. 打包
```
yarn build
```

3. 配置 nginx，将打包后的文件放入 nginx 下
```nginx
location /maputnik {
  alias /Users/xxx/maputnik;
  try_files $uri $uri/ /maputnik/index.html;
}

location ~ .*\.(jpg|jpeg|gif|png|ico|css|js|pdf|txt|woff)$ {
  root /Users/xxx/;
}
```

# client
1. 复制 config.template.json，命名为 config.local.json，配置其中的配置项;
2. 