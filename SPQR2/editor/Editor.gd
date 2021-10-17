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

func get_city_data():
	# check the city data is at least correct and send it all back
	var cities = []
	for city_node in $Cities.get_children():
		# names need to be non zero length and not none
		city_node.check_data()
		var data = city_node.get_data()
		var rcol = get_region_color(city_node.position)
		var index = helpers.get_index_from_region_color(rcol)
		# add this to the city data
		data['id'] = index
		cities.append(data)
		# we need the region id, which is obtained from the region color
	return JSON.print(cities, '  ', true)

func save_data(data):
	var file = File.new()
	file.open('res://editor/output/game_json.json', File.WRITE)
	file.store_string(data)
	file.close()
	helpers.log('Save data to res://editor/output/game_json.json')

func save_all_data():
	var data = get_city_data()
	save_data(data)
	helpers.log('All data exported as JSON')
	get_tree().quit()
