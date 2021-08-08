extends Node

func validateDict(data: Dictionary, items: Array):
	for i in items:
		if not data.has(i):
			return false

func getRegions():
	# load the region json file
	# convert to MapRegion instances
	# return the regions
	var file: File = File.new()
	if file.open('res://data/regions.json', file.READ) != OK:
		helpers.log('Could not read the regions JSON file')
		return null
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		var regions = result.result
		var region_instances: Array = []
		for i in regions:
			validateDict(i, ['name', 'city', 'culture', 'wealth', 'manpower'])
			if i.has('name') and i.has('city') and i.has('culture') and i.has('wealth') and i.has('manpower') and i.has('loyalty'):
				region_instances.append(MapRegion.new(i))
			else:
				helpers.log('JSON region import failed')
				return null
		helpers.log('Loaded %s regions' % str(len(regions)))
		return regions
	else:
		helpers.log('Could not parse regions JSON')
		return null
