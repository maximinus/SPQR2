extends Control

func _ready():
	pass
	
func updateInfo(region: MapRegion):
	# update info according to the region details
	$Mrg/VBox/Banner/Title.text = region.region_name
	$Mrg/VBox/HBCity/CityD.text = region.city
	$Mrg/VBox/HBCulture/CultureD.text = str(region.culture)
	$Mrg/VBox/HBWealth/WealthD.text = str(region.money)
	$Mrg/VBox/HBManpower/ManpowerD.text = str(region.manpower)
	$Mrg/VBox/HBLoyalty/LoyaltyD.text = str(region.loyalty)
