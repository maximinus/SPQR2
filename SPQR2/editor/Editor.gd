extends Node2D

const NODE_RADIUS: float = 24.5
const DATA_FILE = 'res://editor/output/game_data.json'

const DOTTED_LENGTH: float = 6.0
const BORDER_COLOR = Color(0.7, 0.6, 0.5, 1.0)
const ROAD_COLOR = Color(0.8, 0.8, 0.8, 1.0)
const NORMAL_ROAD = Color(0.7, 0.5, 0.3, 1.0)

# Some met-information
export(int) var year
export(int) var gold
export(int) var silver

var region_map: Image
var complete = false
var road_points: Array = []
var road_data: Array = []
var region_data: Array = []

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func _process(delta):
	# all data has been loaded by now
	if complete == false:
		complete = true
		# ensure ids are consistent
		fix_node_ids()
		# make sure roads start and end at node junctions
		update_road_coords()
		# get all the road points
		road_points = get_all_roads()
		# get all the regions
		get_all_regions()
		# build and save all textures
		get_road_textures()
		# do NOT save data here, as multiple _process() will be called
		# as the roads are all rendered from the previous call
	if Input.is_action_just_pressed('quit_editor'):
		get_tree().quit()

func fix_node_ids():
	# for now, we only care that the ID's of nodes are unique
	var index = 0
	for i in $Nodes.get_children():
		i.id = index
		index += 1
	# same for roads
	index = 0
	for i in $Roads.get_children():
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

func get_all_regions():
	for i in $RegionMap/Regions.get_children():
		var region_id = get_region_index(i.rect_position)
		region_data.append({'id':region_id,
							'name':i.region_name,
							'owner_id':i.get_owner_id()})

func get_region_index(pos: Vector2) -> int:
	var rcol = get_region_color(pos)
	return helpers.get_index_from_region_color(rcol)

func get_closest_node(nodes, position):
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
	var pos = get_closest_node(nodes, position)
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
	for rnode in $Roads.get_children():
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
		# allow a border of 4 pixels all sides
		area_size.x = ceil(area_size.x) + 8.0
		area_size.y = ceil(area_size.y) + 8.0
		# adjust viewport sizes
		$ViewC.rect_size = area_size
		$ViewC/Viewport.size = area_size
		# create a new line 2D using the points - area_min so we are at the origin
		
		# now we need to create the lines so we can add to the viewport
		# we have images to create, so this will take a little time
		# for each image we just need the viewport and the points
		# first of all, update the points
				
		var new_points = []
		for i in rnode.points:
			# offset so the image is not clipped at the border
			var lp = Vector2(i[0] - area_min.x, i[1] - area_min.y) + Vector2(4.0, 4.0)
			new_points.append(lp)
				
		# draw all the lines
		var road_types = [[build_default_line(new_points), 'default'],
						  [build_road_line(new_points), 'road'],
						  [build_dotted_line(new_points), 'dotted']]
		
		for i in road_types:
			var all_lines = i[0]
			var folder = i[1]
		
			for j in all_lines:
				$ViewC/Viewport.add_child(j)

			# wait 2 frames is the standard advice
			yield(get_tree(), 'idle_frame')
			yield(get_tree(), 'idle_frame')
			var img = $ViewC/Viewport.get_texture().get_data()
			# due to opengl, image is flipped on the y axis
			img.flip_y()
			# finally, save it
			var filename = 'res://editor/road_images/' + folder + '/road_' + str(rnode.id) + '.png'
			img.save_png(filename)
			helpers.log('Saved ' + filename)
			
			# remove all children ready for next time
			for j in $ViewC/Viewport.get_children():
				j.queue_free()
			# wait a frame for that to be done
			yield(get_tree(), 'idle_frame')
		
		# save the required json data - subtract 4 to allow for spacing
		var loc = area_min - Vector2(4.0, 4.0)
		
		# if this doesn't exist the data is faulty
		var points_data = road_points[rnode.id]
		
		var start_region = get_region_index(rnode.points[0])
		var end_region = get_region_index(rnode.points[-1])
		var all_data = {'id': rnode.id,
						'position': [loc.x, loc.y],
						'points': points_data,
						'condition': rnode.road_state,
						'start_region': start_region,
						'end_region': end_region}
		road_data.append(all_data)
	# now we can save data!
	save_all_data()

func get_player_data():
	var romans = {'name': 'Roman',
				  'id': 0,
				  'gold': gold,
				  'silver': silver}
	var celts = {'name': 'Celts',
				 'id': 1,
				 'gold': 0,
				 'silver': 0}
	return [romans, celts]

func get_game_data():
	return {'game_name':'Test scenario',
			'year': year}

func save_data(data) -> void:
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	var json_data = JSON.print(data, '  ', false)
	file.store_string(json_data)
	file.close()
	helpers.log('Saved roads, nodes and regions to ' + DATA_FILE)

func save_all_data() -> void:
	# this returns a dict of region_id:nodes_in_region
	var all_nodes = get_nodes()
	var all_data = {'nodes': all_nodes,
					'roads': road_data,
					'regions': region_data,
					'players': get_player_data(),
					'game': get_game_data()}
	save_data(all_data)
	helpers.log('All data exported as JSON')

# ==========================================================
# code to render lines
# ==========================================================
func build_road_line(all_points) -> Array:
	# return all the lines we need to add
	var border_line: Line2D = Line2D.new()
	var center_line: Line2D = Line2D.new()
	for i in all_points:
		border_line.add_point(i)
		center_line.add_point(i)
	border_line.width = 3.0
	center_line.width = 1.0
	border_line.antialiased = true
	center_line.antialiased = true
	border_line.default_color = BORDER_COLOR
	center_line.default_color = ROAD_COLOR
	return [border_line, center_line]

func build_default_line(all_points):
	# return the single line as an array
	var road_line: Line2D = Line2D.new()
	for i in all_points:
		road_line.add_point(i)
	road_line.width = 3.0
	road_line.antialiased = true
	road_line.default_color = NORMAL_ROAD
	return [road_line]

func build_dotted_line(all_points) -> Array:
	# return all the lines we need to add
	var all_lines: Array = []
	
	# calculate the length of the line
	var full_length = 0.0
	for i in range(len(all_points) - 1):
		full_length += all_points[i].distance_to(all_points[i + 1])
	
	# now we do essentially the same thing. We loop over all the lines
	var index: int = 0
	var start: Vector2 = all_points[index]
	var end: Vector2 = all_points[index + 1]

	var short_length = all_points[index].distance_to(all_points[index + 1])

	var angle: float = atan2(end.y - start.y, end.x - start.x)
	var offset: Vector2 = Vector2(DOTTED_LENGTH * cos(angle), DOTTED_LENGTH * sin(angle))
	var start_point: Vector2 = start - Vector2(0.0, -1.0)
	
	var dots: float = full_length / DOTTED_LENGTH
	var frac_dots: float = dots - floor(dots)
	var start_length: float = frac_dots / 2.0
	
	start_point += offset * start_length
	var end_point = start_point + offset
	full_length -= start_length
	short_length -= start_length
	
	var draw = true
	while(true):
		# keep calculating until length is exceeded, just as before
		if draw == true:
			var new_line: Line2D = Line2D.new()
			new_line.add_point(start_point)
			
			if short_length < DOTTED_LENGTH:
				end_point = start_point + (offset * (short_length / DOTTED_LENGTH))
			
			new_line.add_point(end_point)
			new_line.width = 2.0
			new_line.antialiased = true
			new_line.default_color = NORMAL_ROAD
			all_lines.append(new_line)
			draw = false
		else:
			draw = true
		start_point += offset
		end_point += offset
		short_length -= DOTTED_LENGTH
		
		if short_length < 0:
			# we have moved onto the next point
			# invert the negative value we have
			short_length *= -1
			# move onto next points
			index += 1
			# have we moved too far?
			if index >= (len(all_points) - 1):
				return all_lines
			# calculate the new offset
			start = all_points[index]
			end = all_points[index + 1]
			angle = atan2(end.y - start.y, end.x - start.x)
			offset = Vector2(DOTTED_LENGTH * cos(angle), DOTTED_LENGTH * sin(angle))				
			start_point = start
			# just need a small line to draw
			end_point = start + (offset * (short_length / DOTTED_LENGTH))
			# calculate new short length
			short_length = all_points[index].distance_to(all_points[index + 1]) - short_length
			# do we need to draw this? (logic has swapped due to loop above)
			if draw == false:
				var corner_line = Line2D.new()
				corner_line.add_point(start_point)
				corner_line.add_point(end_point)
				corner_line.width = 2.0
				corner_line.antialiased = true
				corner_line.default_color = NORMAL_ROAD
				all_lines.append(corner_line)
			start_point = end_point
			end_point += offset
	# needed to make the editor happy
	return(all_lines)
