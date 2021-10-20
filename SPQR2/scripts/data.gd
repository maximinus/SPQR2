extends Node

# all main data is kept here, as well as the code to load it
# JSON error checking is a different step;
# it should be run in a pre-build step

const ROME_DEFAULT_COLOR = Color(0.91, 0.0664, 0.0664, 1.0)
const GAME_DATA = 'res://data/game_data.json'
const ROAD_DATA = 'res://data/road_data.json'

# regions are loaded per id, i.e. id 0 is the first region
var regions: Array = []
var armies: Array = []
var land_paths: Array = []
var sea_paths: Array = []
var roads: Array = []

var enemies: Array = []

# define a light-weight road class
class Road:
	var id: int
	var filepath: String
	var pos: Vector2
	var points: Array
	var start_region: int
	var end_region: int
	
	func _init(data: Dictionary):
		id = data['id']
		filepath = data['file']
		pos = Vector2(data['position'][0], data['position'][1])
		points = data['points']
		start_region = data['start_region']
		end_region = data['end_region']
	
	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false


# this is main() function: it should be called when the game scene starts
func load_all_data() -> bool:
	# return false if there was an issue
	var file: File = File.new()
	if file.open(GAME_DATA, file.READ) != OK:
		helpers.log('Could not read ' + GAME_DATA)
		return false
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		var data = result.result
		regions = get_regions(data['REGIONS'])
		land_paths = get_paths(data['PATHS'])
		enemies = get_enemies(data['ENEMIES'])
		armies = get_armies(data['ARMIES'])
	if get_road_data() == true:
		return true
	helpers.log('Failed to parse ' + GAME_DATA)
	return false

func get_road_data() -> bool:
	var file: File = File.new()
	if file.open(ROAD_DATA, file.READ) != OK:
		helpers.log('Could not read ' + ROAD_DATA)
		return false
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		return true
	helpers.log('Failed to parse ' + ROAD_DATA)
	# now we have the data, let's parse it
	var data = result.result
	for single_road in data:
		roads.append(Road.new(single_road))
	# sort the roads by index
	roads.sort_custom(Road, 'sort')
	return false

func get_regions(region_data: Array) -> Array:
	var region_instances: Array = []
	for i in region_data:
		region_instances.append(MapRegion.new(i))
	helpers.log('Loaded %s regions' % str(len(region_instances)))
	return region_instances

func get_paths(path_data) -> Array:
	var path_instances: Array = []
	for i in path_data['LAND']:
		path_instances.append(i)
	helpers.log('Got %s paths' % len(path_instances))
	return path_instances

func get_enemies(enemy_data: Array) -> Array:
	var enemy_instances: Array = []
	for i in enemy_data:
		enemy_instances.append(EnemyAI.new(i))
	helpers.log('Got %s enemies' % len(enemy_instances))
	return enemy_instances

func get_armies(army_data: Array) -> Array:
	var army_instances: Array = []
	for i in army_data:
		army_instances.append(Army.new(i))
	helpers.log('Got %s armies' % len(army_instances))
	return army_instances

# all methods to get data follow here
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
	for i in data.enemies:
		for j in i.regions:
			region_owners.append([j, i.base_color])
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
	for i in enemies:
		if unit_id in i.armies:
			return i.id
	helpers.log('Error: invalid unit id')
	return -1

func get_armies_in_region(region_id: int) -> Array:
	var in_region: Array = []
	for i in armies:
		if region_id == i.location:
			in_region.append(i)
	return in_region
