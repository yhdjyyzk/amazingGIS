### 制作 `mbtiles`
在 `mapdata/data/pbf` 下运行：
```bash
docker run -v ./:/srv -i -t --rm tilemaker --input /srv/china-latest.osm.pbf --output=/srv/china_1.mbtiles --merge /srv/taiwan-latest.osm.pbf
```

### 增加 `water ploygon shp`
需要将 `config.json` 中的 `shp` 文件目录改为对应到 `docker` 的目录。
```bash
docker run -v /Users/xxx/work/workspace/opengis/mapdata/data/pbf:/srv -i -t --rm tilemaker --input /srv/china-latest.osm.pbf --output=/srv/china_water.mbtiles --merge /srv/taiwan-latest.osm.pbf --config /srv/config.json
```
