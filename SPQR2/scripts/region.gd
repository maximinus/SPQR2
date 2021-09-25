extends Node

class_name MapRegion

var region_name: String
var city: String
var culture: int
var money: int
var manpower: int
var loyalty: int
var color: Array
var owned_by: int

func _init(data: Dictionary):
	# if it doesn't exist, return a null
	# have to check manually, no exceptions!
	self.region_name = data['name']
	self.city = data['city']
	self.culture = data['culture']
	self.money = data['wealth']
	self.manpower = data['manpower']
	self.loyalty = data['loyalty']
	self.color = data['color']
	# owner not set
	self.owned_by = -1

func matchColor(g, b):
	if(g == self.color[1] and b == self.color[2]):
		return true
	return false

static func getMatch(g, b):
	# given the 2 colors, match the region
	for i in data.regions:
		if i.matchColor(g, b):
			return i
	# no match
	return null
