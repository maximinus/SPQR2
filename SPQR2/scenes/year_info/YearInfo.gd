extends MarginContainer

func _ready():
	pass

func get_number_string(value: int):
	# add the comma to the int when converting to a string
	if value < 1000:
		return str(value)
	var thousands: int = int(floor(value / 1000.0))
	var units: int = value - int(thousands * 1000)
	return '%s,%s' % [str(thousands), str(units)]

func set_gold_silver(gold: int, silver: int):
	%GAmount.text = get_number_string(gold)
	%SAmount.text = get_number_string(silver)
