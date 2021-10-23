extends Node

# all main data is kept here, as well as the code to load it
# JSON error checking is a different step;
# it should be run in a pre-build step

const ROME_DEFAULT_COLOR = Color(0.91, 0.0664, 0.0664, 1.0)
const GAME_DATA = 'res://data/game_data.json'
const ROAD_DATA = 'res://data/road_data.json'
const REGION_DATA = 'res://data/region_data.json'

# regions are loaded per id, i.e. id 0 is the first region
var regions: Array = []
var armies: Array = []
var land_paths: Array = []
var sea_paths: Array = []
var roads: Array = []
var roads_built: Array = []
var road_images: Array = []
var enemies: Array = []

var road_texture: ImageTexture = null

# define a light-weight road class
class Road:
	var id: int
	var filepath: String
	var pos: Vector2
	var points: Array
	var start_region: int
	var end_region: int
	var rimage: Image
	
	func _init(data: Dictionary):
		id = data['id']
		filepath = data['file']
		pos = Vector2(data['position'][0], data['position'][1])
		points = data['points']
		start_region = data['start_region']
		end_region = data['end_region']
		rimage = null
	
	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

func get_json_data(filepath):
	# read the data and convert
	# return null if failed
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

# this is main() function: it should be called when the game scene starts
func load_all_data() -> bool:
	# return false if there was an issue
	var region_json = get_json_data(REGION_DATA)
	if region_json == null:
		return false
	regions = get_regions(region_json)
	
	var data = get_json_data(GAME_DATA)
	if data == null:
		return false
	
	# grab all normal_data
	roads_built = data['ROADS']
	enemies = get_enemies(data['ENEMIES'])
	armies = get_armies(data['ARMIES'])
	
	if get_road_data() == true:
		load_road_images()
		build_roads()
		return true
	helpers.log('Failed to parse ' + GAME_DATA)
	return false

func get_road_data() -> bool:
	var data = get_json_data(ROAD_DATA)
	if data == null:
		return false
	for single_road in data:
		roads.append(Road.new(single_road))
	# sort the roads by index
	roads.sort_custom(Road, 'sort')
	return true

class RegionIndexSorter:
	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

func get_regions(region_data: Array) -> Array:
	var region_instances: Array = []
	for i in region_data:
		region_instances.append(MapRegion.new(i))
	helpers.log('Loaded %s regions' % str(len(region_instances)))
	region_instances.sort_custom(RegionIndexSorter, 'sort')
	return region_instances

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

# code for road image generation
func load_road_images() -> void:
	# we have the filenames, so load them. They are already in index order
	var count = 0
	for i in roads:
		var new_image = Image.new()
		var foo = new_image.load('res://gfx/roads/road_' + str(i.id) + '.png')
		i.rimage = new_image
		count += 1
	helpers.log('Loaded ' + str(count) + ' road images')

func build_roads() -> void:
	var road_image = Image.new()
	road_image.create(cn.MAP_PIXEL_SIZE.x, cn.MAP_PIXEL_SIZE.y, false, Image.FORMAT_RGBA8)
	# now blit all the roads (all just for testing)
	for i in roads_built:
		var road_data = roads[i]		
		var rect = Rect2(0.0, 0.0, road_data.rimage.get_width(), road_data.rimage.get_height())
		road_image.blend_rect(road_data.rimage, rect, road_data.pos)
	# the resultant needs to be an ImageTexture
	road_texture = ImageTexture.new()
	road_texture.create_from_image(road_image)

# code for handling money
func get_player_gold():
	return enemies[0].gold

func get_player_silver():
	return enemies[0].silver
