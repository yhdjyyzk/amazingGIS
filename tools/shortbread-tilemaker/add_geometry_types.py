#! /usr/bin/env python3

import argparse
import json
import sys

def compare_layer_lists(vector_layers, tilestats_layers):
    layers1 = [ l["id"] for l in vector_layers ].sort()
    layers2 = [ l["layer"] for l in tilestats_layers ].sort()
    return layers1 == layers2

def validate_tilestats(tilestats):
    """Check if tilestats is valid."""
    ts = tilestats["tilestats"]
    layers = ts.get("layers", [])
    if len(layers) == 0:
        sys.stderr.write("ERROR: tilestats.layers is empty or missing.\n")
        exit(1)
    if len(layers) != ts.get("layerCount"):
        sys.stderr.write("ERROR: tilestats.layerCount is missing or does not match tilestats.layers.\n")
        exit(1)
    for layer in layers:
        if "layer" not in layer:
            sys.stderr.write("ERROR: tilestats.layers[].layer is missing for at least one entry.\n")
            exit(1)
        if "geometry" not in layer:
            sys.stderr.write("ERROR: tilestats.layers[].geometry is missing for at least one entry.\n")
            exit(1)
        geometry = layer["geometry"]
        if geometry not in ["Point", "LineString", "Polygon"]:
            sys.stderr.write("ERROR: Layer {} has an invalid geometry type (valid: Point, LineString, Polygon).\n".format(layer["layer"]))
            exit(1)


def validate_vector_layers(data):
    """Check if all layers have at least one attribute."""
    layers = data["vector_layers"]
    for l in layers:
        if len(l.get("fields", [])) == 0:
            sys.stderr.write("ERROR: Layer {} has no fields. OGR will do a sequential read on all tiles of the requested zoom level!\n".format(l["id"]))
            exit(1)


parser = argparse.ArgumentParser(description="Convert a metadata.json file created by Tilelive/Tessera into a metadata.json file needed by GDAL's MVT driver.")
parser.add_argument("input_file", type=argparse.FileType("r"), help="Input metadata.json file")
parser.add_argument("tilestats_file", type=argparse.FileType("r"), help="Geometry definitions for layers (contains a JSON with a tileStats field)")
args = parser.parse_args()

# Read input file
input_data = json.load(args.input_file)
if "json" in input_data:
    # vector_layers as encoded JSON – this is the metadata.json written by mbutil
    json_data = json.loads(input_data["json"])
    validate_vector_layers(json_data)
elif "vector_layers" in input_data:
    # vector_layers as JSON attribute – this is the metadata.json written by Tilemaker
    validate_vector_layers(input_data)
    json_data = {"vector_layers": input_data["vector_layers"], "tilestats": input_data.get("tilestats", {})}
else:
    sys.stderr.write("Cannot find member 'json' or 'vector_layers' in input metadata.json file\n")
    exit(1)

if "tilestats" not in json_data or json_data["tilestats"] == {}:
    # Read tilestats_file
    tilestats = json.load(args.tilestats_file)
    validate_tilestats(tilestats)
    if "tilestats" not in tilestats:
        sys.stderr.write("Tilestats file misses 'tilestats' member.\n")
        exit(1)
    json_data["tilestats"] = tilestats["tilestats"]
    if len(json_data["tilestats"]["layers"]) != json_data["tilestats"]["layerCount"]:
        sys.stderr.write("Length of tilestats.layers does not match tilestats.layerCount!\n")
        exit(1)
    if not compare_layer_lists(json_data["vector_layers"], json_data["tilestats"]["layers"]):
        sys.stderr.write("Layer lists of vector_layers and tilestats.layers differ.\n")
        exit(1)
else:
    sys.stderr.write("Ignoring tilestats file because input file contains a tilestats property already\n")
    validate_tilestats(json_data)

input_data["json"] = json.dumps(json_data)
input_data.pop("vector_layers", None)
input_data.pop("tilestats", None)

sys.stdout.write(json.dumps(input_data))
