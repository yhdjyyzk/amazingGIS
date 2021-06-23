# opengis
#### 地理可视化实现方案

#### 软件
* `mapbox-gl@1.13.0`，必须使用 `2.0.0` 版本以下. 由于 `mapbox-gl@2.0.0` 协议升级，此版本及以上必须使用 `accessToken`,已经不可在内网使用，并且对源码修改作出了限制，不可修改与 `mapbox` 匿名数据统计的代码.
* [`node-fontnik`](https://github.com/mapbox/node-fontnik) mapbox 字体生成工具
* `geoserver`
* [Maputnik](https://github.com/maputnik/editor)  一个实现了[mapbox样式规范](https://www.mapbox.com/mapbox-gl-style-spec/)的样式编辑器
* [tippecanoe](https://github.com/mapbox/tippecanoe) 可以从 GeoJSON，CSV，Geobuf 来创建矢量瓦片
* [使用GeoServer 和 mapbox-gl 搭建离线地图服务](https://zhuanlan.zhihu.com/p/203756597)  
  ./code/geoserver_learn Map.vue

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
