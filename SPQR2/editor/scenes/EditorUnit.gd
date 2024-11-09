@tool
extends Sprite2D

@export var city_name: String = 'None'
@export var population: int = 0: set = set_population
@export var culture: int = 0
@export var wealth: int = 0
@export var manpower: int = 0
@export var romanisation: int = 0

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
