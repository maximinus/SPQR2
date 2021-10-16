extends Control

func _ready():
	pass
	
func update_info(region: MapRegion) -> void:
	# update info according to the region details
	$Mrg/VBox/Title.text = region.region_name
	$Mrg/VBox/HBCulture/CultureD.text = str(region.culture)
	$Mrg/VBox/HBWealth/WealthD.text = str(region.money)
	$Mrg/VBox/HBManpower/ManpowerD.text = str(region.manpower)
	$Mrg/VBox/HBLoyalty/LoyaltyD.text = str(region.loyalty)
	if region.city != null:
		$Mrg/VBox/HBCity/CityD.text = region.city.city_name
	else:
		$Mrg/VBox/HBCity/CityD.text = "N/A"
	update_army_list(region.id)

func update_army_list(region_id: int) -> void:
	var all_armies = data.get_armies_in_region(region_id)
	if len(all_armies) > 3:
		helpers.log('Error: More than 3 armies in a region')
		all_armies = all_armies.slice(0, 2)
	else:
		while len(all_armies) < 3:
			all_armies.append(null)
	var rows = [$Mrg/VBox/Ar1, $Mrg/VBox/Ar2, $Mrg/VBox/Ar3]
	for i in range(3):
		if all_armies[i] == null:
			rows[i].hide()
		else:
			rows[i].show()
			rows[i].get_node('Ar/StrengthLbl').text = str(all_armies[i].strength)
			rows[i].get_node('Ar/MoraleLbl').text = str(all_armies[i].strength)
			rows[i].get_node('Ar/EquipmentLbl').text = str(all_armies[i].strength)
			rows[i].get_node('Ar/TrainingLbl').text = str(all_armies[i].strength)
