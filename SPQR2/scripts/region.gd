extends Node

class_name MapRegion

var region_name: String
var city: String
var culture: int
var money: int
var manpower: int
var loyalty: int

func _init(data: Dictionary):
	# if it doesn't exist, return a null
	# have to check manually, no exceptions!
	self.region_name = data['name']
	self.city = data['city']
	self.culture = data['culture']
	self.money = data['wealth']
	self.manpower = data['manpower']
	self.loyalty = data['loyalty']
