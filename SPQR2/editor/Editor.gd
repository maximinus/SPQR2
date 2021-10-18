extends Node2D

const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)

var region_map: Image
var complete = false

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func _process(delta):
	if complete == false:
		save_all_data()
		get_road_textures()
		complete = true
	if Input.is_action_just_pressed('quit_editor'):
		get_tree().quit()

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
	for rnode in $Roads.get_children():
		var rname = get_road_name(rnode.points[0], rnode.points[-1])

		# get the size and create a viewport of the same size
		# clear the data from the last time
		for i in $ViewC/Viewport.get_children():
			i.queue_free()
		# wait a frame for that to be done
		yield(get_tree(), "idle_frame")

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
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		var img = $ViewC/Viewport.get_texture().get_data()
		# due to opengl, image is flipped on the y axis
		img.flip_y()
		# finally, save it
		var filename = 'res://editor/road_images/' + rname + '.png'
		img.save_png(filename)
		helpers.log('Saved ' + filename)
		helpers.log('quitting...')

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
