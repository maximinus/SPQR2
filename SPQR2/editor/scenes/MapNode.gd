tool
extends Node2D

export(String) var city_name = 'None'
export(int) var population = 0 setget set_population
export(int) var culture = 0
export(int) var wealth = 0
export(int) var manpower = 0
export(int) var romanisation = 0

var id:int = 0

func _ready():
	pass

func set_population(new_pop: int) -> void:
	population = new_pop
	if new_pop > 2:
		$Nodeimage.hide()
		$CityImage.show()
	else:
		$Nodeimage.show()
		$CityImage.hide()

func get_data():
	return {
		'city_name': city_name,
		'population': population,
		'culture': culture,
		'wealth': wealth,
		'manpower': manpower,
		'romanisation': romanisation
	}
