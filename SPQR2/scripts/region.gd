extends Node

class_name MapRegion

var region_name: String
var culture: int
var money: int
var manpower: int
var loyalty: int
var army_pos: Array
var city: City

func _init(data: Dictionary):
	region_name = data['name']
	culture = data['culture']
	money = data['wealth']
	manpower = data['manpower']
	loyalty = data['loyalty']
	army_pos = data['army_pos']
	# check if we have a city
	var city_data = data['city_stats']
	if city_data['population'] > 0:
		city = City.new(city_data)
	else:
		city = null
