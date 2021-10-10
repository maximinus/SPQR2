extends Node

class_name City

var city_name: String
var population: int
var city_pos: Array

func _init(data: Dictionary):
	city_name = data['name']
	population = data['population']
	city_pos = data['city_pos']
