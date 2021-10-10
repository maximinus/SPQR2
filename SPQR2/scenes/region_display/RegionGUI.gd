extends Control

func _ready():
	pass
	
func update_info(region: MapRegion):
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
