# Boundary Labels Shape File

The *boundary_labels* layer uses a shape file of labelling points for administrative polygons as data source
because Tilemaker offers a centroid but no PointOnSurface function. This file explains how to create the shape file.

## Content of the Shape File

The shape file must have the following fields:

* `admin_leve`: value of OSM `admin_level=*` tag
* `name`: value of OSM `name=*` tag
* `name_de`: value of OSM `name:de=*` tag
* `name_en`: value of OSM `name:en=*` tag
* `way_area`: polygon area in ha in Web Mercator projection

The features must be sorted by `way_area` in descending order.

The shape file must contain features with `admin_level=2` and `admin_level=4` only.

## Create Shape File with Osmium, Osm2pgsql and PostGIS

You can create the shape file with Osmium, Osm2pgsql and PostGIS:

Filter the planet dump using Osmium:

```sh
osmium tags-filter -o admin.osm.pbf planet-latest.osm.pbf r/admin_level=2 r/admin_level=4
```

Create database and enable PostGIS and Hstore support (you might have to create the database superuser using `createuser` first):

```sh
createdb -E utf8 -O $USER adminpolygons
psql -d adminpolygons -c "CREATE EXTENSION postgis;"
psql -d adminpolygons -c "CREATE EXTENSION hstore;"
```

Import filtered planet dump:

```sh
osm2pgsql -d adminpolygons --hstore --multi-geometry --latlong admin.osm.pbf
```

Export shape file:

```sh
pgsql2shp -f admin-points.shp adminpolygons "SELECT admin_level, name, tags->'name:de' AS name_de, tags->'name:en' AS name_en, ST_Area(ST_Transform(way, 3857)) / 10000 AS way_area, ST_PointOnSurface(way) AS geom FROM planet_osm_polygon WHERE osm_id < 0 AND boundary = 'administrative' AND admin_level IN ('2', '4') ORDER BY way_area DESC;"
```
