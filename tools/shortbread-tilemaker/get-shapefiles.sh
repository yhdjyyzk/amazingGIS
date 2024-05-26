#! /bin/bash

set -euo pipefail

function download_and_extract {
    URL=$1
    FILE=$2
    START_DIR=$(pwd)
    cd data
    echo "Downloading $URL"
	CURL_TIME_COND_ARG="$FILE"
	if [ ! -e "$FILE" ] ; then
		CURL_TIME_COND_ARG="1 Jan 1970 00:00:00"
	fi
    curl --time-cond "$CURL_TIME_COND_ARG" -LO "$URL"
    unzip -o -u "$FILE"
    cd "$START_DIR"
}

function transform_shp {
    FILE=$1
    OUT_FILE=$2
    ogr2ogr -f "ESRI Shapefile" "$OUT_FILE" "$FILE" -t_srs EPSG:4326 -lco ENCODING=utf8
}

cd "$(dirname "$0")" || exit

mkdir -p data
download_and_extract "https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip" "water-polygons-split-4326.zip"
download_and_extract "https://osmdata.openstreetmap.de/download/simplified-water-polygons-split-3857.zip" "simplified-water-polygons-split-3857.zip"
download_and_extract "https://shortbread-tiles.org/shapefiles/admin-points-4326.zip" "admin-points-4326.zip"
mkdir -p data/simplified-water-polygons-split-4326
transform_shp data/simplified-water-polygons-split-3857/simplified_water_polygons.shp data/simplified-water-polygons-split-4326/simplified_water_polygons.shp
