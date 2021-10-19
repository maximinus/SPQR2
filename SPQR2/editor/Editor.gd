extends Node2D

const CITY_RADIUS: float = 24.5
const JOIN_RADIUS: float = 8.0
const JSON_FILE = 'res://editor/output/road_data.json'
const DATA_FILE = 'res://editor/output/game_data.json'

var region_map: Image
var complete = false

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func _process(delta):
	if complete == false:
		save_all_data()
		update_road_coords()
		get_road_textures()
		complete = true
	if Input.is_action_just_pressed('quit_editor'):
		get_tree().quit()

func get_region_color(pos: Vector2):
	if pos.x >= 0.0 and pos.x < cn.MAP_PIXEL_SIZE.x:
		if pos.y >= 0.0 and pos.y < cn.MAP_PIXEL_SIZE.y:
			# yes, we need to set a color
			return region_map.get_pixel(pos.x, pos.y)
	# error
	helpers.log('Error: Got position outside of map: ' + str(pos))
	get_tree().quit()

func get_region_index(pos: Vector2) -> int:
	var rcol = get_region_color(pos)
	return helpers.get_index_from_region_color(rcol)

func get_closest_node(nodes, position, radius):
	# get the city position or return null as an error
	var detected = null
	for i in nodes:
		var offset = position - i
		offset.x = abs(offset.x)
		offset.y = abs(offset.y)
		var distance = (offset.x * offset.x) + (offset.y * offset.y)
		if sqrt(distance) < CITY_RADIUS:
			# we got our match
			if detected != null:
				helpers.log('Error: Matched path to >1 node')
				return null
			detected = i
	# none found, we still have null
	return detected

func get_matched_node(cities, joins, position):
	var pos = get_closest_node(cities, position, CITY_RADIUS)
	if pos == null:
		pos = get_closest_node(joins, position, JOIN_RADIUS)
	if pos == null:
		helpers.log('Error: No matching node')
		return null
	return pos

func update_road_coords():
	# A road must start or end at a node (a city or a join)
	# all the nodes at that point are placed at the position of the node
	# first gather all the locations of the cities and joins
	var city_nodes = []
	var join_nodes = []
	for i in $Cities.get_children():
		city_nodes.append(i.position)
	for i in $RoadJoins.get_children():
		join_nodes.append(i.position)
	# now cycle through all the roads
	for road in $Roads.get_children():
		# get the start position
		var start = get_matched_node(city_nodes, join_nodes, road.points[0])
		var end = get_matched_node(city_nodes, join_nodes, road.points[-1])
		# update the points if not null
		if start != null:
			road.points[0] = start
		if end != null:
			road.points[-1] = end

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
	var s = '%03d' % get_region_index(start)
	var e = '%03d' % get_region_index(end)
	return s + '_' + e

func get_all_roads() -> Dictionary:
	var roads = {}
	for road_node in $Roads.get_children():
		# let's obtain as a list of points first
		var pts = []
		for i in road_node.points:
			pts.append(i)
		# check the name
		var rname = get_road_name(pts[0], pts[-1])
		if rname in roads:
			helpers.log('Error: Road between regions already exists')
		else:
			roads[rname] = pts
	return roads

func get_road_textures():
	var json_data = []
	for rnode in $Roads.get_children():
		var rname = get_road_name(rnode.points[0], rnode.points[-1])

		# get the size and create a viewport of the same size
		# clear the data from the last time
		for i in $ViewC/Viewport.get_children():
			i.queue_free()
		# wait a frame for that to be done
		yield(get_tree(), 'idle_frame')

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
		# allow a border of 4 pixels all sides
		area_size.x = ceil(area_size.x) + 8.0
		area_size.y = ceil(area_size.y) + 8.0
		# adjust viewport sizes
		$ViewC.rect_size = area_size
		$ViewC/Viewport.size = area_size
		# create a new line 2D using the points - area_min so we are at the origin
		# add an offset of (4,4)
		var nline1 = Line2D.new()
		var nline2 = Line2D.new()
		for i in rnode.points:
			var lp = Vector2(i[0] - area_min.x, i[1] - area_min.y) + Vector2(4.0, 4.0)
			nline1.add_point(lp)
			nline2.add_point(lp)
		# set aesthetics
		nline1.width = 3.0
		nline1.default_color = Color(1.0, 1.0, 1.0, 1.0)
		# draw line2d at (0,0) on the viewport
		nline1.position = Vector2(0.0, 0.0)

		nline2.width = 4.0
		nline2.default_color = Color(1.0, 1.0, 1.0, 0.8)
		# draw line2d at (0,0) on the viewport
		nline2.position = Vector2(0.0, 0.0)	
		$ViewC/Viewport.add_child(nline1)
		$ViewC/Viewport.add_child(nline2)
		# wait 2 frames is the standard advice
		yield(get_tree(), 'idle_frame')
		yield(get_tree(), 'idle_frame')
		var img = $ViewC/Viewport.get_texture().get_data()
		# due to opengl, image is flipped on the y axis
		img.flip_y()
		# finally, save it
		var filename = 'res://editor/road_images/' + rname + '.png'
		img.save_png(filename)
		# save the required json data - subtract 4 to allow for spacing
		var loc = area_min - Vector2(4.0, 4.0)
		json_data.append([filename, [loc.x, loc.y]])
		helpers.log('Saved ' + str(json_data[-1]))
	save_road_data(json_data)
	helpers.log('quitting...')

func save_road_data(road_data):
	var json_string = JSON.print(road_data, '  ', true)
	var file = File.new()
	file.open(JSON_FILE, File.WRITE)
	file.store_string(json_string)
	file.close()
	helpers.log('Saved road data to ' + JSON_FILE)

func save_data(data):
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	file.store_string(data)
	file.close()
	helpers.log('Saved region data to ' + DATA_FILE)

func save_all_data():
	var uloc = get_unit_locations()
	var rpos = get_all_roads()
	var data = get_city_data(uloc)
	save_data(data)
	helpers.log('All data exported as JSON')
