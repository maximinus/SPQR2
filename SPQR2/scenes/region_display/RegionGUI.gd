extends Control

func _ready():
	pass
	
func updateInfo(region: MapRegion):
	# update info according to the region details
	$Mrg/VBox/Banner/Title.text = region.region_name
	$Mrg/VBox/HBCity/CityD.text = region.city
	$Mrg/VBox/HBCulture/CultureD.text = region.culture
	$Mrg/VBox/HBWealth/WealthD.text = region.money
	$Mrg/VBox/HBManpower/ManpowerD.text = region.manpower
	$Mrg/VBox/HBLoyalty/LoyaltyD.text = region.loyalty
