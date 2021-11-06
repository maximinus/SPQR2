extends Node2D

const NODE_RADIUS: float = 24.5
const JSON_FILE = 'res://editor/output/road_data.json'
const DATA_FILE = 'res://editor/output/region_data.json'

var region_map: Image
var complete = false
var road_points: Array = []

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func _process(delta):
	# all data has been loaded by now
	if complete == false:
		fix_node_ids()
		save_all_data()
		update_road_coords()
		#get_road_textures()
		complete = true
	if Input.is_action_just_pressed('quit_editor'):
		get_tree().quit()

func fix_node_ids():
	# for now, we only care that the ID's of nodes are unique
	var index = 0
	for i in $Nodes.get_children():
		i.id = index
		index += 1

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
	# get the node position or return null as an error
	var detected = null
	for i in nodes:
		var offset = position - i
		var distance = sqrt((offset.x * offset.x) + (offset.y * offset.y))
		if distance < NODE_RADIUS:
			# we got our match
			if detected != null:
				helpers.log('Error: Matched path to >1 node at ' + str(i))
				return null
			detected = i
	# none found, we still have null
	if detected == null:
		print('No node at ' + str(position))
	return detected

func get_matched_node(nodes, position):
	var pos = get_closest_node(nodes, position, NODE_RADIUS)
	if pos == null:
		helpers.log('Error: No matching node')
		return null
	return pos

func update_road_coords() -> void:
	# A road must start or end at a node (a city or a unit)
	# all the nodes at that point are placed at the position of the node
	# first gather all the locations of the nodes
	var nodes = []
	for i in $Nodes.get_children():
		nodes.append(i.position)
	# now cycle through all the roads
	for road in $Roads.get_children():
		# get the start position
		var start = get_matched_node(nodes, road.points[0])
		var end = get_matched_node(nodes, road.points[-1])
		# update the points if not null
		if start != null:
			road.points[0] = start
		if end != null:
			road.points[-1] = end

func get_city_data(locations) -> String:
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

func get_nodes() -> Array:
	# stuff results in a dictionary against the id
	var locations = []
	for i in $Nodes.get_children():
		var node_data: Dictionary = i.get_data()
		var region_id = get_region_index(i.position)
		# convert position to map position
		var map_pos = helpers.pixel_to_map(i.position)
		node_data['region_id'] = region_id
		node_data['position'] = map_pos
		node_data['angle'] = i.rotation_degrees
		node_data['id'] = i.id
		locations.append(node_data)
	return locations

func get_all_roads() -> Array:
	var roads = []
	for road_node in $Roads.get_children():
		# let's obtain as a list of points first
		var pts = []
		for i in road_node.points:
			pts.append([i[0], i[1]])
		roads.append(pts)
	return roads

func get_road_textures() -> void:
	# this code was quite experimental, thus the length
	var json_data = []
	for rnode in $Roads.get_children():
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
		var filename = 'res://editor/road_images/road_' + str(rnode.id) + '.png'
		img.save_png(filename)
		# save the required json data - subtract 4 to allow for spacing
		var loc = area_min - Vector2(4.0, 4.0)
		
		# if this doesn't exist the data is faulty
		var points_data = road_points[rnode.id]
		
		var start_region = get_region_index(rnode.points[0])
		var end_region = get_region_index(rnode.points[-1])
		var all_data = {'id': rnode.id,
						'file': filename,
						'position': [loc.x, loc.y],
						'points': points_data,
						'start_region': start_region,
						'end_region': end_region}
		json_data.append(all_data)
		
		helpers.log('Saved ' + filename)
	save_road_data(json_data)
	helpers.log('quitting...')

func get_node_matching_point(position: Array) -> int:
	var vpos: Vector2 = Vector2(position[0], position[1])
	for i in $Nodes.get_children():
		var offset = vpos - i.position
		var distance = sqrt((offset.x * offset.x) + (offset.y * offset.y))
		if distance < NODE_RADIUS:
			# we got our match
			return i.id
	# this should never happen because of earlier checks
	print('Error: No node to match road')
	return -1
	
func get_astar_data(road_points):
	var road_data = []
	for i in road_points:
		# for every road, we need to compute the start and end nodes
		var start_point = get_node_matching_point(i[0])
		var end_point = get_node_matching_point(i[-1])
		var road = {'points': i, 'start':start_point, 'end':end_point}
		road_data.append(road)
	return road_data

func save_road_data(road_data) -> void:
	var json_string = JSON.print(road_data, '  ', false)
	var file = File.new()
	file.open(JSON_FILE, File.WRITE)
	file.store_string(json_string)
	file.close()
	helpers.log('Saved road data to ' + JSON_FILE)

func save_data(data) -> void:
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	var json_data = JSON.print(data, '  ', false)
	file.store_string(json_data)
	file.close()
	helpers.log('Saved region data to ' + DATA_FILE)

func save_all_data() -> void:
	# this returns a dict of region_id:nodes_in_region
	var all_nodes = get_nodes()
	road_points = get_all_roads()
	var astar_data = get_astar_data(road_points)
	var all_data = {'nodes': all_nodes, 'roads': astar_data}
	save_data(all_data)
	helpers.log('All data exported as JSON')
