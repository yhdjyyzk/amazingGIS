const path = require('path');
const Koa = require('koa');
const Router = require('@koa/router');
const cors = require('koa2-cors');
const staticMiddleWare = require('koa-static');
const MBTiles = require('@mapbox/mbtiles');
const dayjs = require('dayjs');

const router = new Router();
let mbtiles = null;

new MBTiles(path.resolve(__dirname, "../../../mapdata/data/mbtiles/china-shortbread-1.0.mbtiles"), (err, mb) => {
  mbtiles = mb;
});

function getTile (x, y, z) {
  return new Promise((resolve, reject) => {
    mbtiles.getTile(z, x, y, (err, data, headers) => {
      if (err) {
        reject(err);
        return;
      }

      resolve(data);
    })
  })
}

function getNow() {
    return dayjs().format("YYYY-MM-DD HH:mm:ss:SSS");
}

router.get('/tile/:z/:x/:y.pbf', async (ctx, next) => {
  const { x, y, z } = ctx.params;
  const data = await getTile(x, y, z);

  console.log(`INFO: ${getNow()}. Get ${x}_${y}_${z}.`);

  ctx.body = data;

  ctx.set('content-encoding', 'gzip');
  ctx.set('content-type', 'application/x-protobuf');

  return next();
});

const app = new Koa();

app.use(
  cors({
    origin: function (ctx) { //设置允许来自指定域名请求
      // if (ctx.url === '/tile') {
      return '*'; // 允许来自所有域名请求
      // }
    },
    maxAge: 500000000000, //指定本次预检请求的有效期，单位为秒。
    credentials: true, //是否允许发送Cookie
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], //设置所允许的HTTP请求方法'
    allowHeaders: ['Content-Type', 'Authorization', 'Accept'], //设置服务器支持的所有头信息字段
    exposeHeaders: ['WWW-Authenticate', 'Server-Authorization'] //设置获取其他自定义字段
  })
);

app.use(staticMiddleWare(path.resolve(__dirname, '../public/')));
app.use(staticMiddleWare(path.resolve(__dirname, '../../../')));

app.use(router.routes());

app.listen(9001);

console.log(`INFO: ${getNow()}. 启动矢量瓦片引擎.`);
console.log(`INFO: ${getNow()}. listen on port 9001.`);
