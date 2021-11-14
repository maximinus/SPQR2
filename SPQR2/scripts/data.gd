extends Node

# all main data is kept here, as well as the code to load it
# JSON error checking is a different step;
# it should be run in a pre-build step

const GAME_DATA = 'res://data/game_data.json'

# regions are loaded per id, i.e. id 0 is the first region
var regions: Array = []
var rnodes: Array = []
var armies: Array = []
var roads: Array = []
var roads_built: Array = []
var road_images: Array = []
var players: Array = []
# this is the id of the unit with the scenario leader
var leader_unit: int = -1

var road_texture: ImageTexture = null

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

	static func sort(a, b) -> bool:
		if a.id < b.id:
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

# this is main() function: it should be called when the game scene starts
func load_all_data() -> bool:
	# return false if there was an issue
	var game_data = get_json_data(GAME_DATA)
	if game_data == null:
		helpers.log('Error: Could not load ' + GAME_DATA)
		return false
	get_node_data(game_data)
	load_road_images()
	build_roads()
	return true

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
	armies = get_armies(data['nodes'])
	helpers.log('Game data loaded')

func get_armies(nodes: Array) -> Array:
	var new_armies: Array = []
	var army_id = 0
	for i in nodes:
		if i['unit'] >= 0:
			var army_owner = regions[int(i['region_id'])].owner_id
			new_armies.append(Army.new(i, army_owner, army_id))
			army_id += 1
	helpers.log('Got %s armies' % len(new_armies))
	return new_armies

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
	# get an array of [region_id, owner_color]
	# sort by region id ascending and return
	# get all regions and owners
	var region_owners: Array = []
	for i in regions:
		region_owners.append([i.id, players[i.owner_id].base_color])
	# now we have [[region, color], [region, color], sort by region
	region_owners.sort_custom(RegionSorter, 'sort')
	return region_owners

func get_region_owners_texture() -> Image:
	var base_image = Image.new()
	base_image.create(1, len(regions), false, Image.FORMAT_RGB8)
	base_image.lock()
	var ypos: int = 0
	for i in get_ascending_region_colors():
		base_image.set_pixel(0, ypos, i[1])
		ypos += 1		
	base_image.unlock()
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img

func get_army_stats_texture() -> Image:
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
	if unit_id < 0 or unit_id >= len(armies):
		helpers.log('Error: invalid unit id')
		return -1
	return armies[unit_id].owner_id

func get_armies_in_region(region_id: int) -> Array:
	var in_region: Array = []
	for i in armies:
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

# code for handling money
func get_player_gold():
	return players[0].gold

func get_player_silver():
	return players[0].silver
