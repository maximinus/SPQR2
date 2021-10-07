extends Node

# all main data is kept here, as well as the code to load it
# JSON error checking is a different step;
# it should be run in the build step

const ROME_DEFAULT_COLOR = Color(0.91, 0.0664, 0.0664, 1.0)

# regions are loaded per id, i.e. id 1 is the first region
var regions: Array = []
var cities: Array = []
var land_paths: Array = []
var sea_paths: Array = []

var enemies: Array = []

func get_regions(region_data: Array) -> Array:
	var region_instances: Array = []
	for i in region_data:
		region_instances.append(MapRegion.new(i))
		cities.append(i['city_pos'])
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

func load_all_data():
	# return false if there was an issue
	var file: File = File.new()
	if file.open('res://data/game_data.json', file.READ) != OK:
		helpers.log('Could not read the game data JSON file')
		return false
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		var data = result.result
		regions = get_regions(data['REGIONS'])
		land_paths = get_paths(data['PATHS'])
		enemies = get_enemies(data['ENEMIES'])
		return true
	helpers.log('Failed to parse game data')
	return false

# all methods to get data follow here
class RegionSorter:
	static func sort(a, b):
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
