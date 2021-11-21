extends Control

func _ready():
	pass
	
func update_info(region) -> void:
	# update info according to the region details
	# TODO: Fix this
	$Mrg/VBox/Title.text = region.region_name
	$Mrg/VBox/HBCulture/CultureD.text = '12'
	$Mrg/VBox/HBWealth/WealthD.text = '12'
	$Mrg/VBox/HBManpower/ManpowerD.text = '12'
	$Mrg/VBox/HBLoyalty/LoyaltyD.text = '12'
	$Mrg/VBox/HBCity/CityD.text = "N/A"
	update_army_list(region.id)

func update_army_list(region_id: int) -> void:
	var all_units = data.get_units_in_region(region_id)
	if len(all_units) > 3:
		helpers.log('Error: More than 3 armies in a region')
		all_units = all_units.slice(0, 2)
	else:
		while len(all_units) < 3:
			all_units.append(null)
	var rows = [$Mrg/VBox/Ar1, $Mrg/VBox/Ar2, $Mrg/VBox/Ar3]
	for i in range(3):
		if all_units[i] == null:
			rows[i].hide()
		else:
			rows[i].show()
			var strength = str(all_units[i].strength)
			# strip last 3 values and add k
			strength = strength.substr(0, len(strength) - 3) + 'k'
			rows[i].get_node('Ar/StrengthLbl').text = strength
			rows[i].get_node('Ar/MoraleLbl').text = str(all_units[i].morale)
			rows[i].get_node('Ar/EquipmentLbl').text = str(all_units[i].equipment)
			rows[i].get_node('Ar/TrainingLbl').text = str(all_units[i].training)
