extends Node2D

const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)

var region_map: Image

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func _process(_delta):
	# this code will run and exit immediatly
	# do on the process to allow all other nodes to be populated
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

func get_road_name(start: Vector2, end: Vector2) -> String:
	# get a name for the road
	var s = '%02d' % get_region_index(start)
	var e = '%02d' % get_region_index(end)
	return s + '_' + e

func get_all_roads() -> Dictionary:
	var roads = {}
	for road_node in $Roads.get_children():
		# let's obtain as a list of points first
		var pts = []
		for i in road_node.points:
			pts.append(i)
		# now get the texture image
		var rname = get_road_name(pts[0], pts[-1])
		var img = get_road_texture(road_node, rname)
		if rname in roads:
			helpers.log('Error: Road between regions already exists')
		else:
			roads[rname] = pts
	return roads

func get_road_texture(rnode, rname):
	# get the size and create a viewport of the same size
	# ouch, has to be manual. Invert the logic; min must start big and reduce
	var area_min = Vector2(0.0, 0.0) + cn.MAP_PIXEL_SIZE
	var area_max = Vector2(0.0, 0.0)
	for i in rnode.points:
		area_min.x = min(area_min.x, i[0])
		area_min.y = min(area_min.y, i[1])
		area_max.x = max(area_max.x, i[0])
		area_max.y = max(area_max.y, i[1])
	# size can now be calculated
	var area_size = area_max - area_min
	area_size.x = ceil(area_size.x)
	area_size.y = ceil(area_size.y)
	print(area_size)
	#var filename = 'res://editor/road_images/' + rname + '.png'
	#rname.save_png()

func save_data(data):
	var file = File.new()
	file.open('res://editor/output/game_data.json', File.WRITE)
	file.store_string(data)
	file.close()
	helpers.log('Save data to res://editor/output/game_data.json')

func save_all_data():
	var uloc = get_unit_locations()
	var rpos = get_all_roads()
	var data = get_city_data(uloc)
	save_data(data)
	helpers.log('All data exported as JSON')
	get_tree().quit()
