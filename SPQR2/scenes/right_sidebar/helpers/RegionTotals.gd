extends MarginContainer

func _ready():
	pass

func update_data(region_data):
	# add up or average for all nodes
	var pop = 0
	var roman = 0
	var wealth = 0
	var happy = 0
	var christian = 0
	for i in region_data.nodes:
		pop += i.population
		roman += i.romanisation
		wealth += i.wealth
		happy += i.happiness
		christian += i.christianty
	var total_items = float(len(region_data.nodes))
	roman = int(roman / total_items)
	happy = int(happy / total_items)
	christian = int(christian / total_items)
	$HBox/Population.set_icon_text(str(pop))
	$HBox/Roman.set_icon_text(str(roman))
	$HBox/Money.set_icon_text(str(wealth))
	$HBox/Happy.set_icon_text(str(happy))
	$HBox/Christian.set_icon_text(str(christian))
