extends Node

class_name MapRegion

var region_name: String
var city: String
var culture: int
var money: int
var manpower: int
var loyalty: int

func _init(name, c: String, cl: int, m: int, man: int, l: int):
	self.region_name = name
	self.city = c
	self.culture = cl
	self.money = m
	self.manpower = man
	self.loyalty = l

static func getRegions():
	# load the region json file
	# convert to MapRegion instances
	# return the regions
	var file: File = File.new()
	if file.open('res://data/regions.json', file.READ) != OK:
		print('Shit the bed because of file reading')
		return null
	var text: String = file.get_as_text()
	file.close()
	var result: JSONParseResult = JSON.parse(text)
	if result.error == OK:
		var regions = result.result
		print(regions)
		return regions
	else:
		print('Shit the bed here')
		return null
