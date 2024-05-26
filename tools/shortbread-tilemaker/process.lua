-- SPDX-License-Identifier: FTWPL
-- Data processing for Geofabrik Vector Tiles schema
-- Copyright (c) 2021, Geofabrik GmBH
-- Licensed under FTWPL

-- Enter/exit Tilemaker
function init_function()
end
function exit_function()
end

node_keys = { "place", "highway", "railway", "aeroway", "amenity", "aerialway", "shop", "leisure", "tourism", "man_made", "historic", "emergency", "office", "addr:housenumber", "addr:housename" }

-- Management of accepted key-value pairs for the "pois" layer.
-- We write only whitelisted tags to the shape file.

-- A table listing all OSM values accepted for a given OSM key.
-- This is implemented by using the OSM values as keys in the Lua table and assigning the value true to them.
function Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- Check if provided OSM tag value is accepted. If true, return it. If false, return nil.
---- We return an empty string because Tilemaker cannot write NULL values into vector tiles.
function valueAcceptedOrNil(set, osm_value)
	if set[osm_value] then
		return osm_value
	end
	return nil
end

function nilToEmptyStr(arg)
	if arg == nil then
		return ""
	end
	return arg
end

-- Process node tags

poi_amenity_values = Set { "police", "fire_station", "post_box", "post_office", "telephone",
	"library", "townhall", "courthouse", "prison", "embassy", "community_centre", "nursing_home",
	"arts_centre", "grave_yard", "marketplace", "recycling", "university", "school", "college", "public_building",
	"pharmacy", "hospital", "clinic", "doctors", "dentist", "veterinary", "theatre", "nightclub", "cinema",
	"restaurant", "fast_food", "cafe", "pub", "bar", "foot_court", "biergarten", "shelter",
	"car_rental", "car_wash", "car_sharing", "bicycle_rental", "vending_machine", "bank", "atm",
	"toilets", "bench", "drinking_water", "fountain", "hunting_stand", "waste_basket", "place_of_worship" }
catering_values = Set { "restaurant", "fast_food", "pub", "bar", "cafe" }
poi_leisure_values = Set { "playground", "dog_park", "sports_centre", "pitch", "swimming_pool", "water_park",
	"golf_course", "stadium", "ice_rink" }
sport_values = Set { "pitch", "sports_centre" }
poi_tourism_values = Set { "hotel", "motel", "bed_and_breakfast", "guest_house", "hostel", "chalet",
	"camp_site", "alpine_hut", "caravan_site", "information", "picnic_site", "viewpoint", "zoo", "theme_park" }
poi_shop_values = Set { "supermarket", "bakery", "kiosk", "mall", "department_store", "general",
	"convenience", "clothes", "florist", "chemist", "books", "butcher", "shoes", "alcohol",
	"beverages", "optician", "jewelry", "gift", "sports", "stationery", "outdoor", "mobile_phone",
	"toys", "newsagent", "greengrocer", "beauty", "video", "car", "bicycle", "doityourself",
	"hardware", "furniture", "computer", "garden_centre", "hairdresser", "travel_agency", "laundry",
	"dry_cleaning" }
poi_man_made_values = Set { "surveillance", "tower", "windmill", "lighthouse", "wastewater_plant",
	"water_well", "watermill", "water_works" }
poi_historic_values = Set { "monument", "memorial", "artwork", "castle", "ruins", "archaelogical_site",
	"wayside_cross", "wayside_shrine", "battlefield", "fort" }
poi_emergency_values = Set { "phone", "fire_hydrant", "defibrillator" }
poi_highway_values = Set { "emergency_access_point" }
poi_office_values = Set { "diplomatic" }

inf_zoom = 99

-- The height of one floor, in meters
BUILDING_FLOOR_HEIGHT = 3.66

function fillWithFallback(value1, value2, value3)
	if value1 ~= "" then
		return value1
	end
	if value2 ~= "" then
		return value2
	end
	return value3
end

-- Set name, name_en, and name_de on any object
function setNameAttributes()
	local name = Find("name")
	local name_de = Find("name:de")
	local name_en = Find("name:en")
	Attribute("name", fillWithFallback(name, name_en, name_de))
	Attribute("name_de", fillWithFallback(name_de, name, name_en))
	Attribute("name_en", fillWithFallback(name_en, name, name_de))
end

-- Return true if way is oneway
function isOneway(oneway)
	return oneway == "yes" or oneway == "1" or oneway == "true" or oneway == "-1"
end

-- Return true if way is a reverse oneway
function isReverseOneway(oneway)
	return oneway == "-1"
end

-- Add the value of an OSM key if it exists. If the object does not have that key, add NULL.
function addAttributeOrEmptyStr(key)
	local value = Find(key)
	if value ~= "" then
		Attribute(key, value)
	else
		Attribute(key, "")
	end
end

-- Replace nil by an empty string
function toEmptyStr(arg)
	if arg == nil then
		return ""
	end
	return arg
end

-- Add a boolean attribute if the OSM object has the provided key and its value is "yes".
-- Defaults to false/no.
function addAttributeBoolean(key)
	local value = Find(key)
	AttributeBoolean(key, (value == "yes"))
end

-- Convert layer tag to a number between -7 and +7, defaults to 0.
function layerNumeric()
	local layer = tonumber(Find("layer"))
	if not (layer == nil) then
		if layer > 7 then
			layer = 7
		elseif layer < -7 then
			layer = -7
		end
		return layer
	end
	return 0
end

-- Set z_order
function setZOrder(is_rail, ignore_bridge)
	local highway = Find("highway")
	local railway = Find("railway")
	local layer = tonumber(Find("layer"))
	local zOrder = 0
	local Z_STEP = 14
	if not ignore_bridges and toBridgeBool() then
		zOrder = zOrder + Z_STEP
	elseif toTunnelBool() then
		zOrder = zOrder - Z_STEP
	end
	if not (layer == nil) then
		if layer > 7 then
			layer = 7
		elseif layer < -7 then
			layer = -7
		end
		zOrder = zOrder + layer * Z_STEP
	end
	local hwClass = 0
	if is_rail and railway == "rail" and not Holds("service") then
		hwClass = 13
	elseif is_rail and railway == "rail" then
		hwClass = 12
	elseif is_rail and (railway == "subway" or railway == "light_rail" or railway == "tram" or railway == "funicular" or railway == "monorail") then
		hwClass = 11
	elseif highway == "motorway" then
		hwClass = 10
	elseif highway == "trunk" then
		hwClass = 9
	elseif highway == "primary" then
		hwClass = 8
	elseif highway == "secondary" then
		hwClass = 7
	elseif highway == "tertiary" then
		hwClass = 6
	elseif highway == "unclassified" or highway == "residential" or highway == "road" or highway == "motorway_link" or highway == "trunk_link" or highway == "primary_link" or highway == "secondary_link" or highway == "tertiary_link" or highway == "busway" or highway == "bus_guideway" then
		hwClass = 5
	elseif highway == "living_street" or highway == "pedestrian" then
		hwClass = 4
	elseif highway == "service" then
		hwClass = 3
	elseif highway == "footway" or highway == "bridleway" or highway == "cycleway" or highway == "path" or highway == "track" then
		hwClass = 2
	elseif highway == "steps" or highway == "platform" then
		hwClass = 1
	end
	zOrder = zOrder + hwClass
	ZOrder(zOrder)
end

function process_place_layer()
	local place = Find("place")
	local mz = 99
	local kind = place
	local population = Find("population")
	if place == "city" then
		mz = 6
		if population == "" then
			population = "100000"
		end
	elseif place == "town" then
		mz = 7
		if population == "" then
			population = "5000"
		end
	elseif place == "village" then
		mz = 10
		if population == "" then
			population = "100"
		end
	elseif place == "hamlet" then
		mz = 10
		if population == "" then
			population = "50"
		end
	elseif place == "suburb" then
		mz = 10
		if population == "" then
			population = "1000"
		end
	elseif place == "quarter" then
		mz = 10
		if population == "" then
			population = "500"
		end
	elseif place == "neighbourhood" then
		mz = 10
		if population == "" then
			population = "100"
		end
	elseif place == "locality" or place == "island" then
		mz = 10
		if population == "" then
			population = "0"
		end
	elseif place == "isolated_dwelling" or place == "farm" then
		mz = 10
		if population == "" then
			population = "5"
		end
	end
	if (place == "city" or place == "town" or place == "village" or place == "hamlet") and Holds("capital") then
		local capital = Find("capital")
		if capital == "yes" then
			mz = 4
			kind = "capital"
		elseif capital == "4" then
			mz = 4
			kind = "state_capital"
		end
	end
	if mz < 99 then
		Layer("place_labels", false)
		MinZoom(mz)
		Attribute("kind", kind)
		setNameAttributes()
		local populationNum = tonumber(population)
		if populationNum ~= nil then
			AttributeNumeric("population", populationNum)
			ZOrder(populationNum)
		end
	end
end

function process_public_transport_layer(is_area)
	local railway = Find("railway")
	local aeroway = Find("aeroway")
	local aerialway = Find("aerialway")
	local highway = Find("highway")
	local amenity = Find("amenity")
	local kind = ""
	local mz = inf_zoom
	if railway == "station" or railway == "halt" then
		kind = railway
		mz = 13
	elseif railway == "tram_stop" then
		kind = railway
		mz = 14
	elseif highway == "bus_stop" then
		kind = highway
		mz = 14
	elseif amenity == "bus_station" then
		kind = amenity
		mz = 13
	elseif amenity == "ferry_terminal" then
		kind = amenity
		mz = 12
	elseif aerialway == "station" then
		kind = "aerialway_station"
		mz = 13
	elseif aeroway == "aerodrome" then
		kind = aeroway
		mz = 11
	elseif aeroway == "helipad" then
		kind = aeroway
		mz = 13
	end
	if is_area then
		LayerAsCentroid("public_transport")
	else
		Layer("public_transport", false)
	end
	MinZoom(11)
	Attribute("kind", kind)
	local iata = Find("iata")
	if iata ~= "" then
		Attribute("iata", iata)
	end
	setNameAttributes()
end

function node_function()
	-- Layer place_labels
	if Holds("place") and Holds("name") then
		process_place_layer()
	end
	-- Layer street_labels_points
	local highway = Find("highway")
	if highway == "motorway_junction" then
		Layer("street_labels_points", false)
		MinZoom(12)
		Attribute("kind", highway)
		setNameAttributes()
		Attribute("ref", Find("ref"))
	end
	-- Layer public_transport
	local railway = Find("railway")
	local aeroway = Find("aeroway")
	local aerialway = Find("aerialway")
	local amenity = Find("amenity")
	local highway = Find("highway")

	if railway == "station"
	or railway == "halt"
	or railway == "tram_stop"
	or highway == "bus_stop"
	or amenity == "bus_station"
	or amenity == "ferry_terminal"
	or aeroway == "aerodrome"
	or aeroway == "helipad"
	or aerialway == "station" then
		process_public_transport_layer(false)
	end

	-- Layer pois
	-- Abort here if it was written as POI because Tilemaker cannot write a feature to two layers.
	if process_pois(false) then
		return
	end

	-- Layer addresses
	local housenumber = Find("addr:housenumber")
	local housename = Find("addr:housename")
	if housenumber ~= "" or housename ~= "" then
		process_addresses(false)
	end
end

function zmin_for_area(min_square_pixels, way_area)
	-- Return minimum zoom level where the area of the way/multipolygon is larger than
	-- the provided threshold.
	local circumfence = 40052725.78
	local zmin = (math.log((min_square_pixels * circumfence^2) / (2^16 * way_area))) / (2 * math.log(2))
	return math.floor(zmin)
end

function zmin_for_length(min_length_pixels)
	-- Return minimum zoom level where the length of a line is larger than
	-- the provided threshold.
	local length = Length()
	local circumfence = 40052725.78
	local zmin = (math.log((circumfence * min_length_pixels) / (2^8 * length))) / math.log(2)
	return math.floor(zmin)
end

function process_water_polygons(way_area)
	local waterway = Find("waterway")
	local natural = Find("natural")
	local water = Find("water")
	local landuse = Find("landuse")
	local mz = inf_zoom
	local kind = ""
	local is_river = (natural == "water" and water == "river") or waterway == "riverbank"
	if landuse == "reservoir" or landuse == "basin" or (natural == "water" and not is_river) or natural == "glacier" then
		mz = math.max(4, zmin_for_area(0.01, way_area))
		if mz >= 10 then
			mz = math.max(10, zmin_for_area(0.1, way_area))
		end
		if landuse == "reservoir" or landuse == "basin" then
			kind = landuse
		elseif natural == "water" or natural == "glacier" then
			kind = natural
		end
	elseif is_river or waterway == "dock" or waterway == "canal" then
		mz = math.max(4, zmin_for_area(0.1, way_area))
		kind = waterway
                if is_river then
			kind = "river"
		end
	end
	if mz < inf_zoom then
		local way_area = way_area
		Layer("water_polygons", true)
		MinZoom(mz)
		Attribute("kind", kind)
		AttributeNumeric("way_area", way_area)
		ZOrder(way_area)
		if Holds("name") then
			LayerAsCentroid("water_polygons_labels")
			MinZoom(14)
			Attribute("kind", kind)
			AttributeNumeric("way_area", way_area)
			ZOrder(way_area)
			setNameAttributes()
		end
	end
end

function process_water_lines()
	local kind = Find("waterway")
	local mz = inf_zoom
	local mz_label = inf_zoom
	-- skip if area > 0 (it's no line then)
	mz = inf_zoom
	if kind == "river" or kind == "canal" then
		mz = math.max(9, zmin_for_length(0.25))
		mz_label = math.max(13, zmin_for_length(0.25))
	elseif kind == "canal" then
		mz = 12
		mz_label = 14
	elseif kind == "drain" or kind == "stream" then
		mz = 13
		mz_label = 14
	elseif kind == "ditch" then
		mz = 14
		mz_label = 14
	end
	if mz < inf_zoom then
		local tunnel = toTunnelBool(Find("tunnel"), Find("covered"))
		local bridge = toBridgeBool(Find("bridge"))
		local layer = layerNumeric()
		Layer("water_lines", false)
		MinZoom(mz)
		Attribute("kind", kind)
		AttributeBoolean("tunnel", tunnel)
		AttributeBoolean("bridge", bridge)
		ZOrder(layer)
		if Holds("name") then
			Layer("water_lines_labels", false)
			MinZoom(mz_label)
			Attribute("kind", kind)
			AttributeBoolean("tunnel", tunnel)
			AttributeBoolean("bridge", bridge)
			setNameAttributes()
			ZOrder(layer)
		end
	end
end

-- Return value for kind field of pier_* layers.
function get_pier_featuretype()
	local man_made = Find("man_made")
	if man_made == "pier" or man_made == "breakwater" or man_made == "groyne" then
		return man_made
	end
	return nil
end

function process_pier_lines()
	local kind = get_pier_featuretype()
	if kind ~= nil then
		Layer("pier_lines", false)
		MinZoom(12)
		Attribute("kind", kind)
	end
end

function process_pier_polygons()
	local kind = get_pier_featuretype()
	if kind ~= nil then
		Layer("pier_polygons", true)
		MinZoom(12)
		Attribute("kind", kind)
	end
end

function process_land()
	local landuse = Find("landuse")
	local natural = Find("natural")
	local wetland = Find("wetland")
	local leisure = Find("leisure")
	local kind = ""
	local mz = inf_zoom
	if landuse == "forest" or natural == "wood" then
		kind = "forest"
		mz = 7
	elseif landuse == "residential" or landuse == "industrial" or landuse == "commercial" or landuse == "retail" or landuse == "railway" or landuse == "landfill" or landuse == "brownfield" or landuse == "greenfield" or landuse == "farmyard" or landuse == "farmland" then
		kind = landuse
		mz = 10
	elseif landuse == "grass" or landuse == "meadow" or landuse == "orchard" or landuse == "vineyard" or landuse == "allotments" or landuse == "village_green" or landuse == "recreation_ground" or landuse == "greenhouse_horticulture" or landuse == "plant_nursery" or landuse == "quarry" then
		kind = landuse
		mz = 11
	elseif natural == "sand" or natural == "beach" then
		kind = natural
		mz = 10
	elseif natural == "wood" or natural == "heath" or natural == "scrub" or natural == "grassland" or natural == "bare_rock" or natural == "scree" or natural == "shingle" or natural == "sand" or natural == "beach" then
		kind = natural
		mz = 11
	elseif wetland == "swamp" or wetland == "bog" or wetland == "string_bog" or wetland == "wet_meadow" or wetland == "marsh" then
		kind = wetland
		mz = 11
	elseif Find("amenity") == "grave_yard" then
		kind = "grave_yard"
		mz = 13
	elseif landuse == "garages" then
		kind = landuse
		mz = 12
	elseif leisure == "golf_course" or leisure == "park" or leisure == "garden" or leisure == "playground" or leisure == "miniature_golf" then
		kind = leisure
		mz = 11
	elseif landuse == "cemetery" then
		kind = "cemetery"
		mz = 13
	end
	if mz < inf_zoom then
		Layer("land", true)
		MinZoom(mz)
		Attribute("kind", kind)
	end
end

function process_sites()
	local kind = ""
	local amenity = Find("amenity")
	local military = Find("military")
	local leisure = Find("leisure")
	local landuse = Find("landuse")
	local mz = inf_zoom
	if amenity == "university" or amenity == "hospital" or amenity == "prison" or amenity == "parking" or amenity == "bicycle_parking" or amenity == "school" or amenity == "college" then
		kind = amenity
		mz = 14
	elseif leisure == "sports_center" then
		kind = leisure
		mz = 14
	elseif landuse == "construction" then
		kind = landuse
		mz = 14
	elseif military == "danger_area" then
		kind = military
		mz = 14
	end
	if mz < inf_zoom then
		Layer("sites", true)
		MinZoom(mz)
		Attribute("kind", kind)
	end
end

function process_boundary_lines()
	if Holds("type") then
		return
	end
	local min_admin_level = 99
	local disputedBool = false
	while true do
		local rel = NextRelation()
		if not rel and min_admin_level == 99 then
			return
		elseif not rel then
			break
		end
		local admin_level = FindInRelation("admin_level")
		local boundary = FindInRelation("boundary")
		local al = 99
		if admin_level ~= nil and boundary == "administrative" then
			al = tonumber(admin_level)
		end
		if al ~= nil and al >= 2 then
			min_admin_level = math.min(min_admin_level, al)
		end
		if boundary == "disputed" then
			disputedBool = true
		end
	end

	local mz = inf_zoom
	if min_admin_level == 2 then
		mz = 0
	elseif min_admin_level <= 4 then
		mz = 7
	end
	local maritime = Find("maritime")
	local natural = Find("natural")
	local maritimeBool = false
	if maritime == "yes" or natural == "coastline" then
		maritimeBool = true
	end
	if Find("disputed") == "yes" then
		disputedBool = true
	end
	if mz < inf_zoom then
		Layer("boundaries", false)
		MinZoom(mz)
		AttributeNumeric("admin_level", min_admin_level)
		AttributeBoolean("maritime", maritimeBool)
		AttributeBoolean("disputed", disputedBool)
	end
end

function toTunnelBool(tunnel, covered)
	if tunnel == "yes" or tunnel == "culvert" or tunnel == "building_passage" or covered == "yes" then
		return true
	end
	return false
end

function toBridgeBool(bridge)
	if bridge == "yes" or bridge == "viaduct" or bridge == "boardwalk" or bridge == "cantilever" or bridge == "covered" or bridge == "low_water_crossing" or bridge == "movable" or bridge == "trestle" then
		return true
	end
	return false
end

function process_streets()
	local min_zoom_layer = 5
	local mz = inf_zoom
	local kind = ""
	local highway = Find("highway")
	local railway = Find("railway")
	local aeroway = Find("aeroway")
	local surface = Find("surface")
	local bicycle = Find("bicycle")
	local horse = Find("horse")
	local tracktype = Find("tracktype")
	local tunnelBool = toTunnelBool(Find("tunnel"), Find("covered"))
	local covered = Find("covered")
	local service = Find("service")
	local bridgeBool = toBridgeBool(Find("bridge"))
	local name = Find("name")
	local rail = false
	if name == "" then
		name = Find("ref")
	end
	if highway ~= "" then
		if highway == "motorway" or highway == "motorway_link" then
			mz = min_zoom_layer
			kind = "motorway"
		elseif highway == "trunk" or highway == "trunk_link" then
			mz = 6
			kind = "trunk"
		elseif highway == "primary" or highway == "primary_link" then
			mz = 8
			kind = "primary"
		elseif highway == "secondary" or highway == "secondary_link" then
			mz = 9
			kind = "secondary"
		elseif highway == "tertiary" or highway == "tertiary_link" then
			mz = 10
			kind = "tertiary"
		elseif highway == "unclassified" or highway == "residential" or highway == "bus_guideway" or highway == "busway" then
			mz = 12
			kind = highway
		elseif highway == "living_street" or highway == "pedestrian" or highway == "track" then
			mz = 13
			kind = highway
		elseif highway == "service" then
			mz = 14
			kind = highway
		elseif highway == "footway" or highway == "steps" or highway == "path" or highway == "cycleway" then
			mz = 13
			kind = highway
		end
	elseif (railway == "rail" or railway == "narrow_gauge") and service == "" then
		kind = railway
		rail = true
		mz = 8
	elseif ((railway == "rail" or railway == "narrow_gauge") and service ~= "")
		or railway == "light_rail" or railway == "tram" or railway == "subway"
		or railway == "funicular" or railway == "monorail" then
		kind = railway
		rail = true
		mz = 10
	elseif aeroway == "runway" then
		kind = aeroway
		mz = 11
	elseif aeroway == "taxiway" then
		kind = aeroway
		mz = 13
	end
	if kind ~= "" and surface ~= "" then
		if surface == "unpaved" or surface == "compacted" or surface == "dirt" or surface == "earth" or surface == "fine_gravel" or surface == "grass" or surface == "grass_paver" or surface == "gravel" or surface == "ground" or surface == "mud" or surface == "pebblestone" or surface == "salt" or surface == "woodchips" or surface == "clay" then
			suface = "unpaved"
		elseif surface == "paved" or surface == "asphalt" or surface == "cobblestone" or surface == "cobblestone:flattended" or surface == "sett" or surface == "concrete" or surface == "concrete:lanes" or surface == "concrete:plates" or surface == "paving_stones" then
			suface = "unpaved"
		else
			surface = ""
		end
	end
	local link = (highway == "motorway_link" or highway == "trunk_link" or highway == "primary_link" or highway == "secondary_link" or highway == "tertiary_link")
	local layer = tonumber(Find("layer"))
	if layer == nil then
		layer = 0
	end
	local oneway = Find("oneway")
	local onewayBool = not rail and isOneway(oneway)
	local reverseOnewayBool = not rail and isReverseOneway(oneway)
	if mz <= 13 then
		Layer("streets_med", false)
		MinZoom(mz)
		Attribute("kind", kind)
		AttributeBoolean("link", link)
		Attribute("surface", surface)
		AttributeBoolean("tunnel", tunnelBool)
		AttributeBoolean("bridge", bridgeBool)
		if tracktype ~= "" then
			Attribute("tracktype", tracktype)
		end
		AttributeBoolean("rail", rail)
		if service ~= "" then
			Attribute("service", service)
		end
		setZOrder(rail, false)
	end
	if mz < inf_zoom then
		Layer("streets", false)
		MinZoom(mz)
		Attribute("kind", kind)
		AttributeBoolean("link", link)
		Attribute("surface", surface)
		Attribute("bicycle", bicycle)
		Attribute("horse", horse)
		AttributeBoolean("tunnel", tunnelBool)
		AttributeBoolean("bridge", bridgeBool)
		AttributeBoolean("oneway", onewayBool)
		AttributeBoolean("oneway_reverse", reverseOnewayBool)
		if tracktype ~= "" then
			Attribute("tracktype", tracktype)
		end
		AttributeBoolean("rail", rail)
		if service ~= "" then
			Attribute("service", service)
		end
		setZOrder(rail, false)
	end
	if mz <= 10 then
		Layer("streets_low", false)
		MinZoom(mz)
		Attribute("kind", kind)
		AttributeBoolean("rail", rail)
		setZOrder(rail, false)
	end
end

function process_street_labels()
	local highway = Find("highway")
	local ref = Find("ref")
	local name = Find("name")
	local mz = inf_zoom
	local kind = ""
	if highway == "motorway" then
		mz = 10
		kind = highway
	elseif highway == "trunk" or highway == "primary" then
		mz = 12
		kind = highway
	elseif highway == "secondary" or highway == "tertiary" then
		mz = 13
		kind = highway
	elseif highway == "motorway_link" then
		mz = 13
		kind = "motorway"
		link = true
	elseif highway == "trunk_link" then
		mz = 13
		kind = "trunk"
		link = true
	elseif highway == "primary_link" then
		mz = 13
		kind = "primary"
		link = true
	elseif highway == "secondary_link" then
		mz = 13
		kind = "secondary"
		link = true
	elseif highway == "tertiary_link" then
		mz = 14
		kind = "tertiary"
		link = true
	elseif highway == "unclassified" or highway == "residential" or highway == "busway" or highway == "bus_guideway" or highway == "living_street" or highway == "pedestrian" or highway == "track" or highway == "service" or highway == "footway" or highway == "steps" or highway == "path" or highway == "cycleway" then
		mz = 14
		kind = highway
	end
	local refs = ""
	local rows = 0
	local cols = 0
	if mz < inf_zoom and ref ~= "" then
		for word in string.gmatch(ref, "([^;]+);?") do
			rows = rows + 1
			cols = math.max(cols, string.len(word))
			if rows == 1 then
				refs = word
			else
				refs = refs .. "\n" .. word
			end
		end
	elseif mz >= inf_zoom then
		return
	end
	if (name ~= "" or refs ~= "") then
		Layer("street_labels", false)
		MinZoom(mz)
		Attribute("kind", highway)
		AttributeBoolean("tunnel", toTunnelBool())
		Attribute("ref", refs)
		AttributeNumeric("ref_rows", rows)
		AttributeNumeric("ref_cols", cols)
		setNameAttributes()
		setZOrder(false, true)
	end
end

function process_street_polygons()
	local highway = Find("highway")
	local aeroway = Find("area:aeroway")
	local surface = Find("surface")
	local service = Find("service")
	local kind = nil
	local mz = inf_zoom
	if highway == "pedestrian" or highway == "service" then
		mz = 14
		kind = highway
	elseif aeroway == "runway" then
		mz = 11
		kind = aeroway
	elseif aeroway == "taxiway" then
		mz = 13
		kind = aeroway
	end
	if mz < inf_zoom then
		Layer("street_polygons", true)
		MinZoom(mz)
		Attribute("kind", kind)
		if surface ~= "" then
			Attribute("surface", surface)
		end
		AttributeBoolean("tunnel", toTunnelBool(Find("tunnel"), Find("covered")))
		AttributeBoolean("bridge", toBridgeBool(Find("bridge")))
		AttributeBoolean("rail", false)
		if service ~= "" then
			Attribute("service", service)
		end
		setZOrder(rail, false)
		if name ~= "" then
			LayerAsCentroid("streets_polygons_labels")
			setNameAttributes()
			Attribute("kind", kind)
			MinZoom(mz)
		end
	end
end

function process_aerialways()
	local aerialway = Find("aerialway")
	if aerialway == "cable_car" or aerialway == "gondola" or aerialway == "chair_lift" or aerialway == "drag_lift" or aerialway == "t-bar" or aerialway == "j-bar" or aerialway == "platter" or aerialway == "rope_tow" then
		Layer("aerialways", false)
		MinZoom(12)
		Attribute("kind", aerialway)
	end
end

function process_buildings()
	local building = Find("building")
	if building ~= "no" then
		Layer("buildings", true)
		MinZoom(14)
		AttributeNumeric("dummy", 1)
		SetBuildingHeightAttributes()
	end
end

function SetBuildingHeightAttributes()
	local height = tonumber(Find("height"), 10)
	local minHeight = tonumber(Find("min_height"), 10)
	local levels = tonumber(Find("building:levels"), 10)
	local minLevel = tonumber(Find("building:min_level"), 10)

	local renderHeight = BUILDING_FLOOR_HEIGHT
	if height or levels then
		renderHeight = height or (levels * BUILDING_FLOOR_HEIGHT)
	end
	local renderMinHeight = 0
	if minHeight or minLevel then
		renderMinHeight = minHeight or (minLevel * BUILDING_FLOOR_HEIGHT)
	end

	-- Fix upside-down buildings
	if renderHeight < renderMinHeight then
		renderHeight = renderHeight + renderMinHeight
	end

	AttributeNumeric("render_height", renderHeight)
	AttributeNumeric("render_min_height", renderMinHeight)
end

function process_addresses(is_area)
	if is_area then
		LayerAsCentroid("addresses")
	else
		Layer("addresses", false)
	end
	MinZoom(14)
	setAddressAttributes()
end

function setAddressAttributes()
	Attribute("housename", Find("addr:housename"))
	Attribute("housenumber", Find("addr:housenumber"))
end

function process_ferries()
	local mz = inf_zoom
	if Find("route") == "ferry" then
		local motor_vehicle = Find("motor_vehicle")
		mz = 10
		if motor_vehicle == "no" then
			mz = 12
		end
	end
	if mz < inf_zoom then
		Layer("ferries", false)
		MinZoom(mz)
		Attribute("kind", "ferry")
		setNameAttributes()
	end
end

function process_bridges()
	if Find("man_made") == "bridge" then
		Layer("bridges", true)
		MinZoom(12)
		Attribute("kind", "bridge")
	end
end

function process_dam(polygon)
	if Find("waterway") == "dam" then
		if polygon then
			Layer("dam_polygons", true)
		else
			Layer("dam_lines", false)
		end
		MinZoom(12)
		Attribute("kind", "dam")
	end
end

-- Create "pois" layer
-- Returns true if the feature is written to that layer.
-- Returns false if it was no POI we are interested in.
function process_pois(polygon)
	local amenity = valueAcceptedOrNil(poi_amenity_values, Find("amenity"))
	local shop = valueAcceptedOrNil(poi_shop_values, Find("shop"))
	local tourism = valueAcceptedOrNil(poi_tourism_values, Find("tourism"))
	local man_made = valueAcceptedOrNil(poi_man_made_values, Find("man_made"))
	local historic = valueAcceptedOrNil(poi_historic_values, Find("historic"))
	local leisure = valueAcceptedOrNil(poi_leisure_values, Find("leisure"))
	local emergency = valueAcceptedOrNil(poi_emergency_values, Find("emergency"))
	local highway = valueAcceptedOrNil(poi_highway_values, Find("highway"))
	local office = valueAcceptedOrNil(poi_highway_values, Find("office"))
	if amenity == nil and shop == nil and tourism == nil and historic == nil and leisure == nil and emergency == nil and highway == nil and office == nil then
		return false
	end
	if polygon then
		LayerAsCentroid("pois")
	else
		Layer("pois", false)
	end
	MinZoom(14)
	Attribute("amenity", nilToEmptyStr(amenity))
	Attribute("shop", nilToEmptyStr(shop))
	Attribute("tourism", nilToEmptyStr(tourism))
	Attribute("man_made", nilToEmptyStr(historic))
	Attribute("historic", nilToEmptyStr(historic))
	Attribute("leisure", nilToEmptyStr(leisure))
	Attribute("emergency", nilToEmptyStr(emergency))
	Attribute("highway", nilToEmptyStr(highway))
	Attribute("office", nilToEmptyStr(office))
	if catering_values[amenity] then
		addAttributeOrEmptyStr("cuisine")
	end
	if sport_values[leisure] then
		addAttributeOrEmptyStr("sport")
	end
	if amenity == "vending_machine" then
		addAttributeOrEmptyStr("vending")
	end
	if tourism == "information" then
		addAttributeOrEmptyStr("information")
	end
	if man_made == "tower" then
		addAttributeOrEmptyStr("tower:type")
	end
	if amenity == "recycling" then
		addAttributeBoolean("recycling:glass_bottles")
		addAttributeBoolean("recycling:paper")
		addAttributeBoolean("recycling:clothes")
		addAttributeBoolean("recycling:scrap_metal")
	end
	if amenity == "bank" then
		addAttributeBoolean("atm")
	end
	if amenity == "place_of_worship" then
		addAttributeOrEmptyStr("religion")
		addAttributeOrEmptyStr("denomination")
	end
	setNameAttributes()
	setAddressAttributes()
	return true
end

function way_function()
	local area = Area()
	local area_tag = Find("area")
	local type_tag = Find("type")
	local boundary_tag = Find("boundary")
	local area_aeroway_tag = Find("area:aeroway")
	-- Way/Relation is explicitly tagged as area.
	local area_yes_multi_boundary = (
		area_tag == "yes"
		or type_tag == "multipolygon" or type_tag == "boundary"
		or area_aeroway_tag == "runway" or area_aeroway_tag == "taxiway"
		)
	-- Boolean flags for closed ways in cases where features can be mapped as line or area
	-- If closed ways are assumed to be polygons by default except tagged with area=no
	local is_area = (area_yes_multi_boundary or (area > 0 and area_tag ~= "no"))
	-- If closed ways are assumed to be rings by default except tagged with area=yes, type=multipolygon or type=boundary
	local is_area_default_linear = area_yes_multi_boundary

	-- Layers water_polygons, water_polygons_labels, dam_polygons
	if is_area and (Holds("waterway") or Holds("natural") or Holds("landuse")) then
		process_water_polygons(area)
		process_dam(true)
	end
	-- Layers water_lines, water_lines_labels, dam_lines
	if not is_area and Holds("waterway") then
		process_water_lines()
		process_dam(false)
	end

	-- Layer pier_lines, pier_polygons
	local man_made = Find("man_made")
	if not is_area and man_made ~= "" then
		process_pier_lines()
	elseif is_area and man_made ~= "" then
		process_pier_polygons()
	end

	-- Layer bridges
	if is_area and man_made == "bridge" then
		process_bridges()
	end

	-- Layer land
	if is_area and (Holds("landuse") or Holds("natural") or Holds("wetland") or Find("amenity") == "grave_yard" or Holds("leisure")) then
		process_land()
	end

	-- Layer sites
	if is_area and (Holds("amenity") or Holds("leisure") or Holds("military") or Holds("landuse")) then
		process_sites()
	end

	-- Layer boundaries
	process_boundary_lines()

	-- Layer streets, street_labels
	if not is_area_default_linear and (Holds("highway") or Holds("railway") or Holds("aeroway")) then
		process_streets()
		process_street_labels()
	end

	-- Layer street_polygons, street_polygons_labels
	if is_area_default_linear and (Holds("highway") or Holds("area:aeroway")) then
		process_street_polygons()
	end

	-- Layer aerialways
	if Holds("aerialway") then
		process_aerialways()
	end

	-- Layer ferries
	if Find("route") == "ferry" then
		process_ferries()
	end

	-- Layer public_transport
	local railway = Find("railway")
	local aeroway = Find("aeroway")
	local highway = Find("highway")
	local amenity = Find("amenity")
	local aeroway = Find("aeroway")
	if is_area
		and (
			railway == "station"
			or railway == "halt"
			or aeroway == "aerodrome"
			or aeroway == "helipad"
			or highway == "bus_stop"
			or amenity == "bus_station"
			or amenity == "ferry_terminal"
		) then
		process_public_transport_layer(true)
	end

	-- Layer buildings
	if is_area and Holds("building") then
		process_buildings()
	end

	-- Layer pois
	local is_poi = false
	if is_area then
		is_poi = process_pois(true)
	end

	-- Abort here if it was written as POI because Tilemaker cannot write a feature to two layers.
	if is_poi then
		return
	end

	-- Layer addresses
	local housenumber = Find("addr:housenumber")
	local housename = Find("addr:housename")
	if is_area and (housenumber ~= "" or housename ~= "") then
		process_addresses(true)
	end
end

-- Check that admin_level is 2, 3 or 4
function admin_level_valid(admin_level, is_unset_valid)
	return (is_unset_valid and admin_level == "") or admin_level == "2" or admin_level == "3" or admin_level == "4"
end

---- Accept boundary relations
function relation_scan_function()
	if Find("type") ~= "boundary" then
		return
	end
	local boundary = Find("boundary")
	if boundary == "administrative" then
		if admin_level_valid(Find("admin_level"), false) then
			Accept()
		end
	elseif boundary == "disputed" then
		if admin_level_valid(Find("admin_level"), true) then
			Accept()
		end
	end
end

-- Filter shape file attributes
function attribute_function(attr, layer)
	attributes = {}
	if layer == "ocean" then
		attributes = {}
		attributes["x"] = 0
		attributes["y"] = 0
		return attributes
	end
	if layer == "ocean-low" then
		attributes = {}
		attributes["x"] = 0
		attributes["y"] = 0
		return attributes
	end
	if layer == "boundary_labels" then
		attributes = {}
		attributes["admin_level"] = attr["admin_leve"]
		if attributes["admin_level"] == nil then
			attributes["admin_level"] = attr["ADMIN_LEVE"]
		end
		attributes["admin_level"] = tonumber(attributes["admin_level"])
		keys = {"name", "name_de", "name_en", "way_area"}
		for index, value in ipairs(keys) do
			if attr[value] == nil then
				attributes[value] = attr[string.upper(value)]
			else
				attributes[value] = attr[value]
			end
		end
		-- Fill with fallback values if empty
		local name = attributes["name"]
		local name_de = attributes["name_de"]
		local name_en = attributes["name_en"]
		attributes["name"] = fillWithFallback(name, name_en, name_de)
		attributes["name_de"] = fillWithFallback(name_de, name, name_en)
		attributes["name_en"] = fillWithFallback(name_en, name, name_de)
		return attributes
	end
	return attr
end
