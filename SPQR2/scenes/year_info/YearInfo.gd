extends Control

func _ready():
	pass # Replace with function body.

func get_number_string(value: int):
	# add the comma to the int when converting to a string
	if value < 1000:
		return str(value)
	var thousands: int = int(floor(value / 1000.0))
	var units: int = value - int(thousands * 1000)
	return str(thousands) + ',' + str(units)

func set_gold_silver(gold: int, silver: int):
	$Mrg/VBox/Money/GAmount.text = get_number_string(gold)
	$Mrg/VBox/Money/SAmount.text = get_number_string(silver)
