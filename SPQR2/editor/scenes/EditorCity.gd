extends Sprite

export(String) var region_name  = 'None'
export(String) var city_name = 'None'
export(int) var population = 0
export(int) var culture = 0
export(int) var wealth = 0
export(int) var manpower = 0
export(int) var loyalty = 0
export(int) var rural_pop = 0
# ID taken from the region it is in
# but we still need a "node" id
export(int) var id = 0

func _ready():
	pass

func exit_editor() -> void:
	get_tree().quit()

func check_data() -> void:
	if len(region_name) == 0:
		helpers.log('Error: region name not set')
		exit_editor()
	if region_name == 'None':
		helpers.log('Error: region name not changed from default')
		exit_editor()
	if len(city_name) == 0:
		helpers.log('Error: city name not set')
		exit_editor()
	if city_name == 'None':
		helpers.log('Error: city name not changed from default')
		exit_editor()

func get_data() -> Dictionary:
	# build up a dictionary of the data
	var all_data = {}
	var city_data = {}
	# convert to map units here
	if helpers.pixel_on_map(position) == false:
		helpers.log('Error: City not on map')
		exit_editor()
	var map_pos = helpers.pixel_to_map(position)
	city_data['name'] = city_name
	city_data['population'] = population
	city_data['city_pos'] = [map_pos.x, map_pos.y, rotation_degrees]
	all_data['name'] = region_name
	all_data['culture'] = culture
	all_data['wealth'] = wealth
	all_data['manpower'] = manpower
	all_data['loyalty'] = loyalty
	# TODO: Add id in some way
	all_data['city_stats'] = city_data
	return all_data
