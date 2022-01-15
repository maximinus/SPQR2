extends Node

# all main data is kept here, as well as the code to load it
# JSON error checking is a different step;
# it should be run in a pre-build step

const GAME_DATA = 'res://data/game_data.json'

# regions are loaded per id, i.e. id 0 is the first region
var regions: Array = []
var rnodes: Array = []
var units: Array = []
var roads: Array = []
var road_images: Array = []
var players: Array = []
# this is the id of the unit with the scenario leader
var leader_unit: int = -1
# where the mouse is, updated every frame
var current_mouse_coords: Vector2 = Vector2(0.0, 0.0)
var road_texture: ImageTexture = null
# stop thinghs happening if something else is going on
# for now, only set when a unit is move animated
var animation_blocked: bool = false

# define a light-weight road class
class Road:
	var id: int
	var pos: Vector2
	var points: Array
	var start_node: int
	var end_node: int
	var condition: float
	var rimages: Array
	
	func _init(data: Dictionary):
		id = data['id']
		pos = Vector2(data['position'][0], data['position'][1])
		points = data['points']
		start_node = int(data['start_node'])
		end_node = int(data['end_node'])
		condition = float(data['condition'])
		rimages = []

	func get_destination(node_id) -> int:
		# we are at node_id. where does this road take us?
		if start_node == node_id:
			return end_node
		# must be starting at the end, so the end is actually the start
		return start_node

	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

	static func sort_by_start(a, b) -> bool:
		if a.start_node < b.start_node:
			return true
		return false

# do the same for the nodes
class RNode:
	var city_name: String
	var population: float
	var culture: float
	var wealth: int
	var manpower: int
	var romanisation: float
	var region_id: int
	var position: Vector2
	var angle: float
	var id: int

	static func get_pos_data(data) -> Vector2:
		# format is "(value1, value2)"
		var pos_data: String = data['position']
		pos_data = pos_data.substr(1, len(pos_data) - 2)
		var pos_values = pos_data.split(',')
		pos_values[1] = pos_values[1].dedent()
		return Vector2(float(pos_values[0]), float(pos_values[1]))

	func _init(data: Dictionary):
		city_name = data['city_name']
		population = data['population']
		culture = data['culture']
		wealth = int(data['wealth'])
		manpower = int(data['manpower'])
		romanisation = int(data['romanisation'])
		region_id = int(data['region_id'])
		position = RNode.get_pos_data(data)
		angle = float(data['angle'])
		id = data['id']

	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

class MapRegion:
	var id: int
	var owner_id: int
	var region_name: String

	func _init(data: Dictionary):
		id = data['id']
		owner_id = data['owner_id']
		region_name = data['name']
	
	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

class NewMapRegion:
	# use this as a test for the new data for now
	var id: int
	var owner_id: int
	var region_name: String
	var climate: int
	var terrain: int
	var crops: int
	var nodes: Array

	func _init(data: Dictionary):
		region_name = data['name']
		climate = data['climate']
		terrain = data['terrain']
		crops = data['crops']
		nodes = []
	
	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false	

class NewNode:
	var id: int
	# rendered as millions, stored as 10,000's
	var name: String
	var population: int
	var romanisation: int
	var wealth: int
	var happiness: int
	var christianty: int
	var units: Array
	var icons: Array
	
	func _init(data: Dictionary):
		name = data['name']
		population = data['population']
		romanisation = data['romanisation']
		wealth = data['wealth']
		happiness = data['happiness']
		christianty = data['christianity']
		icons = data['icons']
		units = []

class NewUnit:
	var foot: int
	var mounted: int
	var quality: int
	var morale: int

	func _init(data: Dictionary):
		foot = data['foot']
		mounted = data['mounted']
		quality = data['quality']
		morale = data['morale']
	
# this is main() function: it should be called when the game starts
func load_all_data() -> bool:
	# set correct translation
	TranslationServer.set_locale('en')
	# config will always get something
	config.load_config_file()
	config.apply_options()
	# return false if there was an issue
	var game_data = get_json_data(GAME_DATA)
	if game_data == null:
		helpers.log('Error: Could not load ' + GAME_DATA)
		return false
	get_node_data(game_data)
	load_road_images()
	build_roads()
	graph.setup()
	return true

func cleanup():
	# called to quit the game. Performs required cleanup
	config.save_config_file()

func get_json_data(filepath):
	# load a json file, check for errors and then return the data
	# read the data and convert - return null if failed
	var file: File = File.new()
	if file.open(filepath, file.READ) != OK:
		helpers.log('Could not read ' + filepath)
		return null
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		return result.result
	return null

func get_node_data(data):
	for i in data['nodes']:
		rnodes.append(RNode.new(i))
	rnodes.sort_custom(RNode, 'sort')
	for i in data['roads']:
		roads.append(Road.new(i))
	roads.sort_custom(Road, 'sort')
	for i in data['regions']:
		regions.append(MapRegion.new(i))
	regions.sort_custom(MapRegion, 'sort')
	for i in data['players']:
		players.append(EnemyAI.new(i))
	players.sort_custom(EnemyAI, 'sort')
	units = get_units(data['nodes'])
	helpers.log('Game data loaded')

func get_units(unit_data: Array) -> Array:
	# units are the last thing to get, so we have the nodes here
	var new_units: Array = []
	var unit_id = 0
	for i in unit_data:
		if i['unit'] >= 0:
			var unit_owner = regions[int(i['region_id'])].owner_id
			new_units.append(Unit.new(i, unit_owner, unit_id, rnodes[i['id']]))
			unit_id += 1
	helpers.log('Got %s units' % len(new_units))
	return new_units

func set_mouse_coords(coords: Vector2) -> void:
	current_mouse_coords = coords

func get_mouse_coords() -> Vector2:
	return current_mouse_coords

# =======================================================
# all methods to get data follow here
# This is essentially the API to the data stored above
# =======================================================

class RegionSorter:
	static func sort(a, b) -> bool:
		if a[0] < b[0]:
			return true
		return false

func get_ascending_region_colors() -> Array:
	# get an array of [region_id, owner_color1, owner_color2]
	# owner_color_1 is always the lowest value of the 2 owners id
	# sort by region id ascending and return
	# get all regions and owners
	var shared_regions = check_shared_regions()
	var region_owners: Array = []
	for i in regions:
		var base_color = players[i.owner_id].base_color
		region_owners.append([i.id, base_color, base_color])
	# now we have [[region, color], [region, color], sort by region
	region_owners.sort_custom(RegionSorter, 'sort')
	for i in shared_regions:
		# this is [region_id, owner1, owner2]
		region_owners[i[0]] = [i[0], players[i[1]].base_color, players[i[2]].base_color]
	return region_owners

func check_shared_regions() -> Dictionary:
	# check all regions have only units of one color in them
	# go through all units and put owner_id into a region buckets
	var matches = {}
	for i in data.units:
		if matches.has(i.location.region_id):
			if not matches[i.location.region_id].has(i.owner_id):
				matches[i.location.region_id].append(i.owner_id)
		else:
			matches[i.location.region_id] = [i.owner_id]
	# this has now produced a dictionary of all regions
	var regions_with_different_units = []
	for key in matches.keys():
		# all values are unique, so just catch the ones with len > 1
		if len(matches[key]) > 1:
			# add [region, owner1, owner2]
			var data = matches[key]
			data.sort()
			regions_with_different_units.append([key, data[0], data[1]])
	return regions_with_different_units

func get_region_owners_texture() -> Image:
	var base_image = Image.new()
	base_image.create(2, len(regions), false, Image.FORMAT_RGB8)
	base_image.lock()
	var ypos: int = 0
	for i in get_ascending_region_colors():
		# this cycles us through the following
		base_image.set_pixel(0, ypos, i[1])
		# this is the alternate color
		base_image.set_pixel(1, ypos, i[2])
		ypos += 1		
	base_image.unlock()
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img

func get_unit_stats_texture() -> Image:
	var base_image = Image.new()
	base_image.create(1, len(regions), false, Image.FORMAT_RGB8)
	base_image.lock()
	var ypos: int = 0
	for i in data.regions:
		var c: float = (i.manpower * 10.0) / 256.0
		var col: Color = Color(c, c / 1.5, c / 2.0)
		base_image.set_pixel(0, ypos, col)
		ypos += 1		
	base_image.unlock()
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img

func get_money_stats_texture() -> Image:
	var base_image = Image.new()
	base_image.create(1, len(regions), false, Image.FORMAT_RGB8)
	base_image.lock()
	var ypos: int = 0
	for i in data.regions:
		var c: float = (i.money * 14.0) / 256.0
		var col: Color = Color(c / 2.0, c / 2.0, c)
		base_image.set_pixel(0, ypos, col)
		ypos += 1		
	base_image.unlock()
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img

func get_unit_owner(unit_id: int) -> int:
	# get the owner id or -1
	if unit_id < 0 or unit_id >= len(units):
		helpers.log('Error: Out of range unit id')
		return -1
	return units[unit_id].owner_id

func get_unit_move_nodes(unit_id: int) -> PoolIntArray:
	# get the node the unit is in
	return graph.get_connected_nodes(units[unit_id].location.id)

func get_units_in_region(region_id: int) -> Array:
	var in_region: Array = []
	for i in units:
		if region_id == i.get_region_id():
			in_region.append(i)
	return in_region

func get_node_position(node_id):
	return rnodes[node_id].position

# code for road image generation
func load_road_images() -> void:
	# we just id's, but we can guarentee the image is there
	# roads are sorted by id at this point
	# named from worst to best
	var folder_names = ['dotted', 'default', 'road']
	var count = 0
	for i in roads:
		for j in folder_names:
			var limage = load('res://gfx/roads/' + j + '/road_' + str(i.id) + '.png')
			i.rimages.append(limage.get_data())
			count += 1
	helpers.log('Loaded ' + str(count) + ' road images')

func get_road_index_from_condition(condition: float) -> int:
	if condition >= 3.0:
		return 2
	if condition >= 2.0:
		return 1
	return 0

func build_roads() -> void:
	var road_image = Image.new()
	road_image.create(cn.MAP_PIXEL_SIZE.x, cn.MAP_PIXEL_SIZE.y, false, Image.FORMAT_RGBA8)
	# now blit all the roads
	for i in roads:
		var rect = Rect2(0.0, 0.0, i.rimages[0].get_width(), i.rimages[0].get_height())
		# which image to use?
		var image_index = get_road_index_from_condition(i.condition)
		road_image.blend_rect(i.rimages[image_index], rect, i.pos)
	# the resultant needs to be an ImageTexture
	road_texture = ImageTexture.new()
	road_texture.create_from_image(road_image)

func get_roads_starting_at(node_id: int) -> Array:
	var connected_roads = []
	for i in roads:
		if i.start_node == node_id or i.end_node == node_id:
			connected_roads.append(i)
	return connected_roads

func get_road_arrows_from_node_id(node_id: int) -> Array:
	var all_data = []
	for i in get_roads_starting_at(node_id):
		# it either starts or ends here
		var folder_name = '_away'
		if i.start_node != node_id:
			folder_name = '_towards'
		var rimage = load('res://gfx/roads/arrow' + folder_name + '/road_' + str(i.id) + '.png')
		# prevent name clashing - don't call road_texture
		var r_tex = ImageTexture.new()
		r_tex.create_from_image(rimage.get_data())
		
		var red_image = load('res://gfx/roads/red' + folder_name + '/road_' + str(i.id) + '.png')
		var red_texture = ImageTexture.new()
		red_texture.create_from_image(red_image.get_data())
		
		all_data.append(cn.RoadMoveDisplay.new(r_tex, red_texture, i.id, i.pos, i.points))
	return all_data

func move_unit(unit_id, location_id):
	units[unit_id].location = rnodes[location_id]

func node_has_enemy_unit(node_id: int) -> bool:
	# check all units
	for i in units:
		if i.location.id == node_id:
			if i.is_roman() == false:
				return true
	return false

# code for handling money
func get_player_gold():
	return players[0].gold

func get_player_silver():
	return players[0].silver

# functions to return the text for the differing node values
func get_node_population_text(population: float) -> String:
	if population <= 0.1:
		return cn.NodePopulationText[5]
	if population <= 0.4:
		return cn.NodePopulationText[4]
	if population <= 1.0:
		return cn.NodePopulationText[3]
	if population <= 2.0:
		return cn.NodePopulationText[2]
	if population <= 3.0:
		return cn.NodePopulationText[1]
	return cn.NodePopulationText[0]

func get_node_romanisation_text(romanisation) -> String:
	# value is 0 through 9
	if romanisation > 8:
		return cn.NodeRomanisationText[0]
	if romanisation > 6:
		return cn.NodeRomanisationText[1]
	if romanisation > 4:
		return cn.NodeRomanisationText[2]
	if romanisation > 2:
		return cn.NodeRomanisationText[3]
	if romanisation > 0:
		return cn.NodeRomanisationText[4]
	return cn.NodeRomanisationText[5]

func get_node_wealth_text(wealth) -> String:
	# value is from 0 through 9, as above
	if wealth > 8:
		return cn.NodeWealthText[0]
	if wealth > 6:
		return cn.NodeWealthText[1]
	if wealth > 4:
		return cn.NodeWealthText[2]
	if wealth > 2:
		return cn.NodeWealthText[3]
	if wealth > 0:
		return cn.NodeWealthText[4]
	return cn.NodeWealthText[5]

func get_node_happiness(happiness) -> String:
	# 0 through 9, as expected
	if happiness > 8:
		return cn.NodeHappyText[0]
	if happiness > 6:
		return cn.NodeHappyText[1]
	if happiness > 4:
		return cn.NodeHappyText[2]
	if happiness > 2:
		return cn.NodeHappyText[3]
	return cn.NodeHappyText[4]

func get_node_christian_text(christian) -> String:
	# almost the same as above
	if christian == 0:
		return cn.NodeChristianText[6]
	if christian > 8:
		return cn.NodeChristianText[0]
	if christian > 7:
		return cn.NodeChristianText[1]
	if christian > 6:
		return cn.NodeChristianText[2]
	if christian > 5:
		return cn.NodeChristianText[3]
	if christian > 3:
		return cn.NodeChristianText[4]
	return cn.NodeChristianText[5]
