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

func get_status(status: Dictionary) -> void:
	var ownership: Array = status['ownership']
	# this is an array of ints
	var index: int = 0
	# bounds checking is done on the file before running
	for i in regions:
		var owner:int = ownership[index]
		if owner == 0:
			i.owner_color = ROME_DEFAULT_COLOR
		else:
			i.owner_color = enemies[index].base_color
		index += 1

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
		get_status(data['STATUS'])
		return true
	helpers.log('Failed to parse game data')
	return false

# all methods to get data follow here
func get_region_owners_texture() -> Image:
	# build a texture describing the owners of the regions
	# regions are already in the correct order of the array
	# we build with a texture region
	var base_image = Image.new()
	base_image.create(1, len(regions), false, Image.FORMAT_RGB8)
	base_image.lock()
	var ypos: int = 0
	for i in regions:
		base_image.set_pixel(0, ypos, regions[ypos].owner_color)
		ypos += 1
	base_image.unlock()
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img
