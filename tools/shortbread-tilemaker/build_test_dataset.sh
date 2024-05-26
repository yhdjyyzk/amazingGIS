#! /usr/bin/env bash

# Build test dataset

set -euo pipefail

TILEMAKER=${TILEMAKER:-tilemaker}
OSMIUM=${OSMIUM:-osmium}

if [ "$#" -lt 4 ]; then
    echo "ERROR: Wrong Usage"
    echo "Usage: $0 BBOX SMALL_OSM_PBF LARGE_OSM_PBF OUT_DIRECTORY [TILEMAKER_EXTRA_ARGS]"
    exit 1
fi

BBOX=$1
shift
SMALL_OSM_PBF=$1
shift
LARGE_OSM_PBF=$1
shift
OUT_DIR=$1
shift

if [ ! -d "$OUT_DIR" ]; then
    echo "ERROR: Output directory $OUT_DIR does not exist."
    exit 1
fi

EXTRA_ARGS=$@
echo "Make small region."
mkdir -p $OUT_DIR/small
"$TILEMAKER" $EXTRA_ARGS --input $SMALL_OSM_PBF --output $OUT_DIR/small --config config.json --process process.lua

echo "Make large region."
LARGE_OSM_PBF_FILTERED=$(mktemp --suffix .osm.pbf)
"$OSMIUM" tags-filter --overwrite -o $LARGE_OSM_PBF_FILTERED --progress $LARGE_OSM_PBF n/place r/admin_level=2 r/admin_level=4 w/waterway w/highway=motorway w/highway=motorway_link w/highway=trunk w/highway=trunk_link wr/natural=water wr/waterway=riverbank wr/landuse=basin wr/landuse=reservoir wr/natural=glacier wr/waterway=dock wr/waterway=canal wr/landuse=forest
mkdir -p $OUT_DIR/large
jq '.settings.maxzoom |= 7' config.json > config-lowzoom.json
"$TILEMAKER" $EXTRA_ARGS --bbox=$BBOX --input $LARGE_OSM_PBF_FILTERED --output $OUT_DIR/small --config config-lowzoom.json --process process.lua
rm $LARGE_OSM_PBF_FILTERED

echo "Merging"
TMPFILE=$(mktemp)
jq '.maxzoom=14' "$OUT_DIR/small/metadata.json" > "$TMPFILE"
mv "$TMPFILE" "$OUT_DIR/small/metadata.json"

echo "Setting correct maxzoom in metadata.json"
TMPFILE=$(mktemp)
jq '.maxzoom=14' "$OUT_DIR/small/metadata.json" > $TMPFILE
chmod --reference="$OUT_DIR/small/metadata.json" $TMPFILE
chown --reference="$OUT_DIR/small/metadata.json" $TMPFILE
mv $TMPFILE "$OUT_DIR/small/metadata.json"

echo "Result written to $OUT_DIR/small/"
