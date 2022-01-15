extends MarginContainer

func _ready():
	pass

func setup(unit):
	# unit = {'foot': 9000, 'mounted': 2000, 'quality': 8, 'morale': 7}
	$HBox/Foot.text = data.get_troop_numbers(unit['foot'])
	$HBox/Mounted.text = data.get_troop_numbers(unit['mounted'])
	$HBox/Strength.text = str(unit['quality'])
	$HBox/Morale.text = str(unit['morale'])
