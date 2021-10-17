extends Node2D

const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)

var region_map: Image

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()
	# this code will run and exit immediatly
	save_all_data()

func get_region_color(pos: Vector2):
	if pos.x >= 0.0 and pos.x < MAP_PIXEL_SIZE.x:
		if pos.y >= 0.0 and pos.y < MAP_PIXEL_SIZE.y:
			# yes, we need to set a color
			return region_map.get_pixel(pos.x, pos.y)
	# error
	helpers.log('Error: Got position outside of map: ' + str(pos))
	get_tree().quit()

func get_region_index(pos: Vector2) -> int:
	var rcol = get_region_color(pos)
	return helpers.get_index_from_region_color(rcol)

func get_city_data(locations):
	# check the city data is at least correct and send it all back
	var cities = []
	for city_node in $Cities.get_children():
		# names need to be non zero length and not none
		city_node.check_data()
		var data = city_node.get_data()
		# we need the region id, which is obtained from the region color
		var region_id = get_region_index(city_node.position)
		data['id'] = region_id
		# update with unit locations
		if region_id in locations:
			data['army_pos'] = locations[region_id]
		cities.append(data)
	return JSON.print(cities, '  ', true)

func get_unit_locations():
	# stuff results in a dictionary against the id
	var locations = {}
	for unit in $Units.get_children():
		var region_id = get_region_index(unit.position)
		# convert position to map position
		var map_pos = helpers.pixel_to_map(unit.position)
		if region_id in locations:
			locations[region_id].append([map_pos.x, map_pos.y])
		else:
			locations[region_id] = [[map_pos.x, map_pos.y]]
	return locations

func save_data(data):
	var file = File.new()
	file.open('res://editor/output/game_json.json', File.WRITE)
	file.store_string(data)
	file.close()
	helpers.log('Save data to res://editor/output/game_json.json')

func save_all_data():
	var uloc = get_unit_locations()
	var data = get_city_data(uloc)
	save_data(data)
	helpers.log('All data exported as JSON')
	get_tree().quit()
