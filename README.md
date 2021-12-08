# opengis
### 地理数据可视化方案
包括如何使用开源工具搭建地理数据可视化方案以及如何从零打造渲染地理可视化渲染引擎

#### 软件
* [awesome-vector-tiles](https://github.com/mapbox/awesome-vector-tiles) Mapbox 工具集合  
* `mapbox-gl@1.13.0`，必须使用 `2.0.0` 版本以下. 由于 `mapbox-gl@2.0.0` 协议升级, 此版本及以上必须使用. `accessToken`, 已经不可在内网使用，并且对源码修改作出了限制, 不可修改与 `mapbox` 匿名数据统计的代码.  
* [`node-fontnik`](https://github.com/mapbox/node-fontnik) `mapbox` 字体生成工具  
* `geoserver`
* [maputnik](https://github.com/maputnik/editor) 开源的 `mapbox` 样式规范编辑器  
* [tippecanoe](https://github.com/mapbox/tippecanoe) 从大规模 `GeoJSON`, `Geobuf`, 或者 `CSV` 要素创建矢量瓦片 (`vector tilesets`)  
* [tilemaker](https://github.com/systemed/tilemaker)  使用 `OSM` 的 `.osm.pbf` 文件创建 `mbtiles`  
* [vector-tile-js](https://github.com/mapbox/vector-tile-js)解析 `vector-tile` 瓦片  
* [Nominatim](https://github.com/osm-search/Nominatim)  开源的地址解析与逆地址解析工具

#### 系列文章
1. [用60秒浓缩我们在3D地图可视化倾注的热爱](https://zhuanlan.zhihu.com/p/172213877)
2. [打造服务B端客户的酷炫3D地图可视化产品](https://zhuanlan.zhihu.com/p/124197052)
3. [数据源与存储计算](https://zhuanlan.zhihu.com/p/131529483)
4. [地图交互与姿态控制](https://zhuanlan.zhihu.com/p/137503866)
5. [地图文字渲染](https://zhuanlan.zhihu.com/p/142830146)
6. [地图建筑渲染](https://zhuanlan.zhihu.com/p/146151281)
7. [地图建筑建模制作与输出](https://zhuanlan.zhihu.com/p/150257820)
8. [地理数据可视化](https://zhuanlan.zhihu.com/p/158706718)
9. [地图酷炫效果和原理揭秘](https://zhuanlan.zhihu.com/p/163592043)
10. [WebGL 渲染管线在 Web3D 地图中的应用](https://zhuanlan.zhihu.com/p/392415003)
11. [Web 3D地图中CPU和GPU动画的实现](https://zhuanlan.zhihu.com/p/397070898)
12. [使用 RxJS 管理复杂 Web 应用的数据流的实践](https://zhuanlan.zhihu.com/p/409076886)

#### 工程
1. [使用GeoServer 和 mapbox-gl 搭建离线地图服务](https://zhuanlan.zhihu.com/p/203756597)  
2. [如何自制全国 MBTiles 并渲染](https://zhuanlan.zhihu.com/p/390797186)

#### 数据下载
由于数据不合规，所以仅供研究学习，禁止部署于互联网。
- [中国大陆部分数据](https://www.aliyundrive.com/s/bADcdkdVVWw)
- [台湾省部分数据](https://www.aliyundrive.com/s/4wnHse2rzoh)