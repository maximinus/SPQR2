extends Node

# all main data is kept here, as well as the code to load it

var regions: Array = []
var cities: Array = []
var land_paths: Array = []
var sea_paths: Array = []

func validateDict(data: Dictionary, items: Array) -> bool:
	for i in items:
		if not data.has(i):
			helpers.log('Missing dict entry ' + str(i))
			return false
	return true

func getRegions(region_data: Array) -> Array:
	var region_instances: Array = []
	for i in region_data:
		if validateDict(i, ['name', 'city', 'city_pos', 'culture', 'wealth', 'manpower', 'loyalty']) != false:
			region_instances.append(MapRegion.new(i))
			cities.append(i['city_pos'])
		else:
			helpers.log('JSON region import failed')
			return []
	helpers.log('Loaded %s regions' % str(len(region_instances)))
	return region_instances

func getPaths(path_data) -> Array:
	if validateDict(path_data, ['LAND', 'SEA']) == false:
		return []
	var path_instances: Array = []
	for i in path_data['LAND']:
		path_instances.append(i)
	helpers.log('Got %s paths' % len(path_instances))
	return path_instances

func loadAllData():
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
		if validateDict(data, ['REGIONS', 'PATHS']) == false:
			return false
		regions = getRegions(data['REGIONS'])
		land_paths = getPaths(data['PATHS'])
		return true
	helpers.log('Failed to parse game data')
	return false
